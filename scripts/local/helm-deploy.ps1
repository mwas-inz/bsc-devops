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

Write-Host "=== BSC DevOps — Helm Deployment ===" -ForegroundColor Cyan
Write-Host "Release:   $RELEASE"
Write-Host "Namespace: $NAMESPACE"
Write-Host "Image tag: $Tag"

if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: minikube not found. Install it first: https://minikube.sigs.k8s.io/docs/start/" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: helm not found. Install it first: https://helm.sh/docs/intro/install/" -ForegroundColor Red
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
Write-Host "--- helm upgrade --install ---"
helm upgrade --install $RELEASE $CHART `
    --namespace $NAMESPACE `
    --create-namespace `
    --set imageTag=$Tag `
    --wait `
    --timeout 5m

$driver = (minikube profile list --output=json 2>$null | ConvertFrom-Json).valid[0].Config.Driver
Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Pod status:"
kubectl get pods -n $NAMESPACE
Write-Host ""
Write-Host "Access:"
if ($driver -eq 'docker') {
    Write-Host "  Docker driver detected — minikube ip is not reachable from the host." -ForegroundColor Yellow
    Write-Host "  Run in a separate terminal:  minikube tunnel"
    Write-Host "  Then open:                   http://localhost"
} else {
    $MINIKUBE_IP = minikube ip
    Write-Host "  Frontend:  http://$MINIKUBE_IP"
}
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
