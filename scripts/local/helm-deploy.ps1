# Usage: .\scripts\local\helm-deploy.ps1 [-Tag <IMAGE_TAG>]
# Tag defaults to the current git commit SHA (must be pushed to Docker Hub by CI).
#Requires -Version 5.1
param(
    [string]$Tag = (git rev-parse HEAD)
)
$ErrorActionPreference = 'Stop'

$RELEASE   = "bsc-devops"
$NAMESPACE = "bsc-devops"
$CHART     = "infrastructure/helm/bsc-devops"
$CLUSTER   = "bsc-devops"

Write-Host "=== BSC DevOps — Helm Deployment ===" -ForegroundColor Cyan
Write-Host "Release:   $RELEASE"
Write-Host "Namespace: $NAMESPACE"
Write-Host "Image tag: $Tag"

if (-not (Get-Command k3d -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: k3d not found. Install it first: https://k3d.io/stable/#installation" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: helm not found. Install it first: https://helm.sh/docs/intro/install/" -ForegroundColor Red
    exit 1
}

$clusterExists = k3d cluster list 2>$null | Select-String -Pattern "^$CLUSTER"
if (-not $clusterExists) {
    Write-Host "Creating k3d cluster '$CLUSTER'..."
    k3d cluster create $CLUSTER `
        --agents 1 `
        --port "80:80@loadbalancer" `
        --port "443:443@loadbalancer"
}

kubectl config use-context "k3d-$CLUSTER"

Write-Host ""
Write-Host "--- helm upgrade --install ---"
helm upgrade --install $RELEASE $CHART `
    --namespace $NAMESPACE `
    --create-namespace `
    --set imageTag=$Tag `
    --wait `
    --timeout 5m

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
Write-Host "Helm commands:"
Write-Host "  helm status $RELEASE -n $NAMESPACE"
Write-Host "  helm history $RELEASE -n $NAMESPACE"
Write-Host "  helm rollback $RELEASE -n $NAMESPACE"
Write-Host ""
Write-Host "Debug commands:"
Write-Host "  kubectl logs -f deployment/users -n $NAMESPACE"
Write-Host "  kubectl logs -f deployment/tasks -n $NAMESPACE"
Write-Host "  kubectl port-forward svc/users 8080:8080 -n $NAMESPACE"
Write-Host "  kubectl port-forward svc/tasks 8080:8080 -n $NAMESPACE"
