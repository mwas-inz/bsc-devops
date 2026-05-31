#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$NAMESPACE = "bsc-devops"
$INFRA = "infrastructure/local"

Write-Host "=== BSC DevOps — Minikube Deployment ===" -ForegroundColor Cyan

if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: minikube not found. Install it first: https://minikube.sigs.k8s.io/docs/start/" -ForegroundColor Red
    exit 1
}

$minikubeHost = minikube status --format='{{.Host}}' 2>$null
if ($minikubeHost -ne 'Running') {
    Write-Host "Starting minikube (4 CPUs, 4GB RAM)..."
    minikube start --memory=4096 --cpus=4
}

Write-Host ""
Write-Host "Enabling ingress addon..."
minikube addons enable ingress

Write-Host ""
Write-Host "--- Namespace ---"
kubectl apply -f "$INFRA/namespace.yaml"

Write-Host ""
Write-Host "--- Postgres ---"
kubectl apply -f "$INFRA/postgres/postgres-configmap.yaml"
kubectl apply -f "$INFRA/postgres/postgres-pv.yaml"
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
kubectl apply -f "$INFRA/apps/users-deployment.yaml"
kubectl apply -f "$INFRA/apps/tasks-deployment.yaml"
kubectl apply -f "$INFRA/apps/task-archiver-deployment.yaml"

Write-Host ""
Write-Host "--- Frontend ---"
kubectl apply -f "apps/frontend/kubernetes.yml"

Write-Host ""
Write-Host "Waiting for applications..."
kubectl rollout status deployment/users -n $NAMESPACE --timeout=120s
kubectl rollout status deployment/tasks -n $NAMESPACE --timeout=120s
kubectl rollout status deployment/task-archiver -n $NAMESPACE --timeout=120s
kubectl rollout status deployment/frontend -n $NAMESPACE --timeout=120s

$MINIKUBE_IP = minikube ip
Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Pod status:"
kubectl get pods -n $NAMESPACE
Write-Host ""
Write-Host "Access:"
Write-Host "  Frontend:  http://$MINIKUBE_IP"
Write-Host "  Jaeger UI: kubectl port-forward svc/jaeger 16686:16686 -n $NAMESPACE"
Write-Host "             then open http://localhost:16686"
Write-Host ""
Write-Host "Debug commands:"
Write-Host "  kubectl logs -f deployment/users -n $NAMESPACE"
Write-Host "  kubectl logs -f deployment/tasks -n $NAMESPACE"
Write-Host "  kubectl port-forward svc/users 8080:8080 -n $NAMESPACE"
Write-Host "  kubectl port-forward svc/tasks 8081:8081 -n $NAMESPACE"
