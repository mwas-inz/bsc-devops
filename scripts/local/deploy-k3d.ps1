# Usage: .\scripts\local\deploy-k3d.ps1 [-Tag <IMAGE_TAG>]
# Tag defaults to the current git commit SHA (must be pushed to Docker Hub by CI).
#Requires -Version 5.1
param(
    [string]$Tag = (git rev-parse HEAD)
)
$ErrorActionPreference = 'Stop'

$NAMESPACE = "bsc-devops"
$CLUSTER   = "bsc-devops"
$INFRA     = "infrastructure/local"

Write-Host "=== BSC DevOps — k3d Deployment ===" -ForegroundColor Cyan
Write-Host "Image tag: $Tag"

if (-not (Get-Command k3d -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: k3d not found. Install it first: https://k3d.io/stable/#installation" -ForegroundColor Red
    exit 1
}

$clusterExists = k3d cluster list 2>$null | Select-String -Pattern "^$CLUSTER"
if (-not $clusterExists) {
    Write-Host "Creating k3d cluster '$CLUSTER'..."
    k3d cluster create $CLUSTER `
        --agents 2 `
        --port "80:80@loadbalancer" `
        --port "443:443@loadbalancer"
}

kubectl config use-context "k3d-$CLUSTER"

# Applies a manifest file after substituting IMAGE_TAG with $Tag.
function Invoke-KApply([string]$File) {
    (Get-Content $File) -replace 'IMAGE_TAG', $Tag | kubectl apply -f -
}

Write-Host ""
Write-Host "--- Namespace ---"
kubectl apply -f "$INFRA/namespace.yaml"

Write-Host ""
Write-Host "--- Postgres ---"
kubectl apply -f "$INFRA/postgres/postgres-configmap.yaml"
kubectl apply -f "$INFRA/postgres/postgres-pvc.yaml"
kubectl apply -f "$INFRA/postgres/postgres-deployment.yaml"
kubectl apply -f "$INFRA/postgres/postgres-service.yaml"

Write-Host ""
Write-Host "--- Pulsar ---"
kubectl apply -f "$INFRA/pulsar/pulsar-deployment.yaml"
kubectl apply -f "$INFRA/pulsar/pulsar-service.yaml"

Write-Host ""
Write-Host "--- Jaeger ---"
kubectl apply -f "$INFRA/jaeger/jaeger-deployment.yaml"
kubectl apply -f "$INFRA/jaeger/jaeger-service.yaml"

Write-Host ""
Write-Host "Waiting for Postgres..."
kubectl rollout status deployment/postgres -n $NAMESPACE --timeout=120s

Write-Host "Waiting for Pulsar (may take ~2 minutes)..."
kubectl rollout status deployment/pulsar -n $NAMESPACE --timeout=300s

Write-Host ""
Write-Host "--- App config and secrets ---"
kubectl apply -f "$INFRA/apps/db-secret.yaml"
kubectl apply -f "$INFRA/apps/app-config.yaml"

Write-Host ""
Write-Host "--- Applications ---"
Invoke-KApply "$INFRA/apps/users-deployment.yaml"
Invoke-KApply "$INFRA/apps/tasks-deployment.yaml"
Invoke-KApply "$INFRA/apps/task-archiver-deployment.yaml"

Write-Host ""
Write-Host "--- Frontend ---"
Invoke-KApply "apps/frontend/kubernetes.yml"

Write-Host ""
Write-Host "Waiting for applications..."
kubectl rollout status deployment/users -n $NAMESPACE --timeout=120s
kubectl rollout status deployment/tasks -n $NAMESPACE --timeout=120s
kubectl rollout status deployment/task-archiver -n $NAMESPACE --timeout=120s
kubectl rollout status deployment/frontend -n $NAMESPACE --timeout=120s

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Pod status:"
kubectl get pods -n $NAMESPACE
Write-Host ""
Write-Host "Access:"
Write-Host "  Frontend:  http://localhost"
Write-Host "  Jaeger UI: kubectl port-forward svc/jaeger 16686:16686 -n $NAMESPACE"
Write-Host "             then open http://localhost:16686"
Write-Host ""
Write-Host "Debug commands:"
Write-Host "  kubectl logs -f deployment/users -n $NAMESPACE"
Write-Host "  kubectl logs -f deployment/tasks -n $NAMESPACE"
Write-Host "  kubectl port-forward svc/users 8080:8080 -n $NAMESPACE"
Write-Host "  kubectl port-forward svc/tasks 8080:8080 -n $NAMESPACE"
