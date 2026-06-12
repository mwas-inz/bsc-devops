# Usage: .\scripts\local\argocd-update.ps1 -Version <version>
#   e.g. .\scripts\local\argocd-update.ps1 -Version 0.7.0
#
# Updates targetRevision in gitops/application.yaml, commits the change,
# and re-applies the ArgoCD Application resource to the cluster.
# ArgoCD then reconciles the cluster to the new chart version automatically.
#
# Prerequisites: kubectl pointed at the local k3d cluster, ArgoCD running.
param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)
$ErrorActionPreference = "Stop"

$AppFile  = "gitops/application.yaml"
$ArgoCDNs = "argocd"

Write-Host "=== BSC DevOps - ArgoCD Application Update ===" -ForegroundColor Cyan
Write-Host "Target version: $Version"

# ── Prerequisites ─────────────────────────────────────────────────────────────
foreach ($cmd in @("kubectl", "git")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "ERROR: $cmd not found."
    }
}

if (-not (Test-Path $AppFile)) {
    Write-Error "ERROR: $AppFile not found. Run from repository root."
}

# ── Update targetRevision ─────────────────────────────────────────────────────
$content = Get-Content $AppFile -Raw
if ($content -match 'targetRevision:\s+"?([^"\r\n]+)"?') {
    $current = $Matches[1].Trim('"')
} else {
    Write-Error "ERROR: targetRevision not found in $AppFile."
}

if ($current -eq $Version) {
    Write-Host "Already at version $Version — nothing to do."
    exit 0
}

Write-Host ""
Write-Host "--- Updating targetRevision: $current -> $Version ---"
$updated = $content -replace 'targetRevision:.*', "targetRevision: `"$Version`""
Set-Content $AppFile $updated -NoNewline

# ── Commit ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Committing to Git ---"
git add $AppFile
git commit -m "chore(gitops): bump targetRevision to $Version"
git push

# ── Apply to cluster ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Applying Application to cluster ---"
kubectl apply -f $AppFile

Write-Host ""
Write-Host "=== Update Applied ===" -ForegroundColor Green
Write-Host ""
Write-Host "Watching sync status (Ctrl-C to exit):"
kubectl get application bsc-devops -n $ArgoCDNs -w
