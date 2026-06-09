# Usage: .\scripts\local\seal-secrets.ps1
#
# Seals GHCR and Docker Hub credentials using the Sealed Secrets controller
# running in the local k3d cluster. Run this once (or whenever credentials
# rotate), then commit the output files to Git.
#
# Required environment variables:
#   GHCR_TOKEN           — GitHub PAT with read:packages scope (GHCR chart pull)
#   ARGO_DOCKERHUB_TOKEN — Docker Hub PAT with read scope (image pull)
#
# Output (commit these to Git):
#   gitops/secrets/ghcr-docker-config.sealed.yaml
#   gitops/secrets/dockerhub-pull-secret.sealed.yaml
$ErrorActionPreference = "Stop"

$Cluster       = "bsc-devops"
$GhcrUser      = "mwas-inz"
$DockerhubUser = "mateuszwas"

Write-Host "=== BSC DevOps - Seal Secrets ===" -ForegroundColor Cyan

# ── Prerequisites ─────────────────────────────────────────────────────────────
foreach ($cmd in @("kubectl", "helm", "k3d", "kubeseal")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "ERROR: $cmd not found."
    }
}

if (-not $env:GHCR_TOKEN)           { Write-Error "ERROR: GHCR_TOKEN is not set." }
if (-not $env:ARGO_DOCKERHUB_TOKEN) { Write-Error "ERROR: ARGO_DOCKERHUB_TOKEN is not set." }

# ── Cluster + Sealed Secrets controller ───────────────────────────────────────
$clusters = k3d cluster list 2>$null
if (-not ($clusters | Select-String "^$Cluster")) {
    Write-Host "Creating k3d cluster '$Cluster'..."
    k3d cluster create $Cluster `
        --agents 2 `
        --port "80:80@loadbalancer" `
        --port "443:443@loadbalancer"
}
kubectl config use-context "k3d-$Cluster"

$ssStatus = helm status sealed-secrets -n kube-system 2>$null
if (-not $ssStatus) {
    Write-Host "Installing Sealed Secrets controller..."
    helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets --force-update | Out-Null
    helm repo update sealed-secrets | Out-Null
    helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets `
        --namespace kube-system `
        --wait --timeout 2m
} else {
    Write-Host "Sealed Secrets controller already installed."
}

# ── Target namespaces ─────────────────────────────────────────────────────────
kubectl create namespace argocd     --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace bsc-devops --dry-run=client -o yaml | kubectl apply -f -

New-Item -ItemType Directory -Force -Path "gitops/secrets" | Out-Null

# ── Seal GHCR Docker config (argocd namespace) ────────────────────────────────
Write-Host ""
Write-Host "--- Sealing GHCR Docker config (namespace: argocd) ---"
$dockerAuth       = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${GhcrUser}:$($env:GHCR_TOKEN)"))
$dockerConfigJson = "{`"auths`":{`"ghcr.io`":{`"auth`":`"$dockerAuth`"}}}"

kubectl create secret generic ghcr-docker-config `
    --namespace argocd `
    --from-literal="config.json=$dockerConfigJson" `
    --dry-run=client -o yaml `
| kubeseal `
    --controller-namespace kube-system `
    --controller-name sealed-secrets `
    --format yaml `
    | Set-Content "gitops/secrets/ghcr-docker-config.sealed.yaml"

Write-Host "Written: gitops/secrets/ghcr-docker-config.sealed.yaml"

# ── Seal Docker Hub pull secret (bsc-devops namespace) ────────────────────────
Write-Host ""
Write-Host "--- Sealing Docker Hub pull secret (namespace: bsc-devops) ---"
kubectl create secret docker-registry dockerhub-pull-secret `
    --namespace bsc-devops `
    --docker-server=docker.io `
    --docker-username=$DockerhubUser `
    --docker-password=$env:ARGO_DOCKERHUB_TOKEN `
    --dry-run=client -o yaml `
| kubeseal `
    --controller-namespace kube-system `
    --controller-name sealed-secrets `
    --format yaml `
    | Set-Content "gitops/secrets/dockerhub-pull-secret.sealed.yaml"

Write-Host "Written: gitops/secrets/dockerhub-pull-secret.sealed.yaml"

Write-Host ""
Write-Host "=== Sealing Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Commit the sealed files to Git:"
Write-Host "  git add gitops/secrets/"
Write-Host "  git commit -m 'chore(gitops): rotate sealed secrets'"
Write-Host ""
Write-Host "WARNING: Sealed files are bound to cluster '$Cluster' controller key."
Write-Host "Re-run this script after recreating the cluster."
Write-Host ""
Write-Host "Back up the controller key (DO NOT commit to Git):"
Write-Host "  kubectl get secret -n kube-system ``"
Write-Host "    -l sealedsecrets.bitnami.com/sealed-secrets-key ``"
Write-Host "    -o yaml > gitops/secrets/sealed-secrets-key.backup.yaml"
