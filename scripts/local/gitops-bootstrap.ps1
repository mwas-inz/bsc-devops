# Usage: .\scripts\local\gitops-bootstrap.ps1
#
# Full GitOps bootstrap — reproduces the complete local environment from Git.
# No tokens required. All credentials are pre-sealed in gitops/secrets/.
#
# Run order:
#   1. .\scripts\local\seal-secrets.ps1  <- once, when credentials change
#   2. .\scripts\local\gitops-bootstrap.ps1  <- every time you recreate the cluster
#
# What this script does:
#   1. k3d cluster (creates if missing)
#   2. Sealed Secrets controller (Helm, kube-system)
#   3. gitops/secrets/*.sealed.yaml applied — controller decrypts into Secrets
#   4. ArgoCD (Helm, argocd namespace) — mounts ghcr-docker-config for OCI pull
#   5. gitops/application.yaml — ArgoCD syncs bsc-devops chart from GHCR
$ErrorActionPreference = "Stop"

$Cluster   = "bsc-devops"
$ArgocdNs  = "argocd"
$AppNs     = "bsc-devops"

Write-Host "=== BSC DevOps - GitOps Bootstrap ===" -ForegroundColor Cyan

# ── Prerequisites ─────────────────────────────────────────────────────────────
foreach ($cmd in @("kubectl", "helm", "k3d")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "ERROR: $cmd not found."
    }
}

if (-not (Test-Path "gitops/secrets/ghcr-docker-config.sealed.yaml")) {
    Write-Error "ERROR: gitops/secrets/ghcr-docker-config.sealed.yaml not found.`nRun scripts/local/seal-secrets.ps1 first."
}

# ── 1. k3d cluster ────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- [1/5] k3d cluster ---"
$clusters = k3d cluster list 2>$null
if (-not ($clusters | Select-String "^$Cluster")) {
    k3d cluster create $Cluster `
        --agents 2 `
        --port "80:80@loadbalancer" `
        --port "443:443@loadbalancer"
} else {
    Write-Host "Cluster '$Cluster' already running."
}
kubectl config use-context "k3d-$Cluster"

kubectl create namespace $ArgocdNs --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $AppNs    --dry-run=client -o yaml | kubectl apply -f -

# ── 2. Sealed Secrets controller ──────────────────────────────────────────────
Write-Host ""
Write-Host "--- [2/5] Sealed Secrets controller ---"
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets --force-update | Out-Null
helm repo update sealed-secrets | Out-Null
helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets `
    --namespace kube-system `
    --wait --timeout 2m

# ── 3. Apply sealed secrets ───────────────────────────────────────────────────
Write-Host ""
Write-Host "--- [3/5] Sealed secrets ---"
kubectl apply -f gitops/secrets/ghcr-docker-config.sealed.yaml
kubectl apply -f gitops/secrets/dockerhub-pull-secret.sealed.yaml

Write-Host "Waiting for controller to decrypt..."
$pairs = @(
    @{ Name = "ghcr-docker-config";   Ns = $ArgocdNs },
    @{ Name = "dockerhub-pull-secret"; Ns = $AppNs }
)
foreach ($p in $pairs) {
    while (-not (kubectl get secret $p.Name -n $p.Ns 2>$null)) {
        Start-Sleep -Seconds 2
    }
    Write-Host "  Decrypted: $($p.Name) ($($p.Ns))"
}

# ── 4. ArgoCD ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- [4/5] ArgoCD ---"
helm repo add argo https://argoproj.github.io/argo-helm --force-update | Out-Null
helm repo update argo | Out-Null
helm upgrade --install argocd argo/argo-cd `
    --namespace $ArgocdNs `
    --values infrastructure/local/argocd/values.yaml `
    --wait --timeout 5m

# ── 5. Application CRD ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- [5/5] ArgoCD Application ---"
kubectl apply -f gitops/application.yaml

Write-Host ""
Write-Host "=== Bootstrap Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "ArgoCD sync status:"
kubectl get application bsc-devops -n $ArgocdNs 2>$null
Write-Host ""
Write-Host "Pod status (may still be starting):"
kubectl get pods -n $AppNs 2>$null
Write-Host ""
Write-Host "ArgoCD UI:"
Write-Host "  kubectl port-forward svc/argocd-server -n $ArgocdNs 8080:80"
Write-Host "  open http://localhost:8080"
Write-Host ""
Write-Host "Initial admin password:"
Write-Host "  kubectl get secret argocd-initial-admin-secret -n $ArgocdNs ``"
Write-Host "    -o jsonpath='{.data.password}' | % { [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(`$_)) }"
