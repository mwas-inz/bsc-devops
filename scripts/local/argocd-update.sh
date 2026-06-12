#!/bin/bash
# Usage: bash scripts/local/argocd-update.sh <version>
#   e.g. bash scripts/local/argocd-update.sh 0.7.0
#
# Updates targetRevision in gitops/application.yaml, commits the change,
# and re-applies the ArgoCD Application resource to the cluster.
# ArgoCD then reconciles the cluster to the new chart version automatically.
#
# Prerequisites: kubectl pointed at the local k3d cluster, ArgoCD running.
set -euo pipefail

VERSION="${1:-}"
APP_FILE="gitops/application.yaml"
ARGOCD_NS="argocd"

if [[ -z "$VERSION" ]]; then
    echo "Usage: bash scripts/local/argocd-update.sh <version>"
    echo "  e.g. bash scripts/local/argocd-update.sh 0.7.0"
    exit 1
fi

echo "=== BSC DevOps — ArgoCD Application Update ==="
echo "Target version: $VERSION"

# ── Prerequisites ─────────────────────────────────────────────────────────────
for cmd in kubectl sed git; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd not found."
        exit 1
    fi
done

if [[ ! -f "$APP_FILE" ]]; then
    echo "ERROR: $APP_FILE not found. Run from repository root."
    exit 1
fi

# ── Update targetRevision ─────────────────────────────────────────────────────
CURRENT=$(grep 'targetRevision' "$APP_FILE" | awk '{print $2}' | tr -d '"')
if [[ "$CURRENT" == "$VERSION" ]]; then
    echo "Already at version $VERSION — nothing to do."
    exit 0
fi

echo ""
echo "--- Updating targetRevision: $CURRENT → $VERSION ---"
sed -i "s/targetRevision: .*/targetRevision: \"$VERSION\"/" "$APP_FILE"

# ── Commit ────────────────────────────────────────────────────────────────────
echo ""
echo "--- Committing to Git ---"
git add "$APP_FILE"
git commit -m "chore(gitops): bump targetRevision to $VERSION"
git push

# ── Apply to cluster ──────────────────────────────────────────────────────────
echo ""
echo "--- Applying Application to cluster ---"
kubectl apply -f "$APP_FILE"

echo ""
echo "=== Update Applied ==="
echo ""
echo "Watching sync status (Ctrl-C to exit):"
kubectl get application bsc-devops -n "$ARGOCD_NS" -w
