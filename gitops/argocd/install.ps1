# Usage: .\gitops\argocd\install.ps1
#
# Bootstraps the full GitOps stack on a local k3d cluster:
#   1. k3d cluster (if not already running)
#   2. Sealed Secrets controller  — decrypts gitops/secrets/*.sealed.yaml
#   3. Sealed Secrets applied     — GHCR Docker config + Docker Hub pull secret
#   4. ArgoCD                     — uses ghcr-docker-config to pull Helm chart
#   5. ArgoCD Application CRD     — triggers automated sync of bsc-devops chart
#
# No tokens required at runtime. All credentials are pre-sealed in Git.
$ErrorActionPreference = "Stop"

$Cluster         = "bsc-devops"
$ArgocdNamespace = "argocd"
$AppNamespace    = "bsc-devops"

Write-Host "=== BSC DevOps - GitOps Bootstrap ===" -ForegroundColor Cyan

foreach ($cmd in @("kubectl", "helm", "k3d", "kubeseal")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "ERROR: $cmd not found."
    }
}

# ── 1. Cluster ────────────────────────────────────────────────────────────────
$clusters = k3d cluster list 2>$null
if (-not ($clusters | Select-String "^$Cluster")) {
    Write-Host ""
    Write-Host "--- Creating k3d cluster '$Cluster' ---"
    k3d cluster create $Cluster `
        --agents 2 `
        --port "80:80@loadbalancer" `
        --port "443:443@loadbalancer"
}
kubectl config use-context "k3d-$Cluster"

kubectl create namespace $ArgocdNamespace --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $AppNamespace    --dry-run=client -o yaml | kubectl apply -f -

# ── 2. Sealed Secrets controller ──────────────────────────────────────────────
Write-Host ""
Write-Host "--- Installing Sealed Secrets controller ---"
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets --force-update | Out-Null
helm repo update sealed-secrets | Out-Null
helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets `
    --namespace kube-system `
    --wait --timeout 2m

# ── 3. Apply sealed credentials ───────────────────────────────────────────────
Write-Host ""
Write-Host "--- Applying sealed secrets ---"
kubectl apply -f gitops/secrets/ghcr-docker-config.sealed.yaml
kubectl apply -f gitops/secrets/dockerhub-pull-secret.sealed.yaml

Write-Host "Waiting for Sealed Secrets controller to decrypt..."
Start-Sleep -Seconds 10

# ── 4. ArgoCD ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Installing ArgoCD ---"
helm repo add argo https://argoproj.github.io/argo-helm --force-update | Out-Null
helm repo update argo | Out-Null
helm upgrade --install argocd argo/argo-cd `
    --namespace $ArgocdNamespace `
    --values infrastructure/local/argocd/values.yaml `
    --wait --timeout 5m

# ── 5. Application CRD ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Applying ArgoCD Application ---"
kubectl apply -f gitops/application.yaml

Write-Host ""
Write-Host "=== Bootstrap Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "ArgoCD UI (port-forward):"
Write-Host "  kubectl port-forward svc/argocd-server -n $ArgocdNamespace 8080:80"
Write-Host "  then open http://localhost:8080"
Write-Host ""
Write-Host "Initial admin password:"
Write-Host "  kubectl get secret argocd-initial-admin-secret -n $ArgocdNamespace ``"
Write-Host "    -o jsonpath='{.data.password}' | % { [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(`$_)) }"
Write-Host ""
Write-Host "App sync status:"
Write-Host "  kubectl get application bsc-devops -n $ArgocdNamespace"
Write-Host "  kubectl get pods -n $AppNamespace"
