#!/bin/bash
# Usage: bash scripts/local/gitops-bootstrap.sh
#
# Full GitOps bootstrap — reproduces the complete local environment from Git.
# No tokens required. All credentials are pre-sealed in gitops/secrets/.
#
# Run order:
#   1. scripts/local/seal-secrets.sh  ← once, when credentials change
#   2. scripts/local/gitops-bootstrap.sh  ← every time you recreate the cluster
#
# What this script does:
#   1. k3d cluster (creates if missing)
#   2. Sealed Secrets controller (Helm, kube-system)
#   3. gitops/secrets/*.sealed.yaml applied — controller decrypts into Secrets
#   4. ArgoCD (Helm, argocd namespace) — mounts ghcr-docker-config for OCI pull
#   5. gitops/application.yaml — ArgoCD syncs bsc-devops chart from GHCR
set -euo pipefail

CLUSTER="bsc-devops"
ARGOCD_NS="argocd"
APP_NS="bsc-devops"

echo "=== BSC DevOps — GitOps Bootstrap ==="

# ── Prerequisites ─────────────────────────────────────────────────────────────
for cmd in kubectl helm k3d; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd not found."
        exit 1
    fi
done

if [[ ! -f gitops/secrets/ghcr-docker-config.sealed.yaml ]]; then
    echo "ERROR: gitops/secrets/ghcr-docker-config.sealed.yaml not found."
    echo "       Run scripts/local/seal-secrets.sh first."
    exit 1
fi

# ── 1. k3d cluster ────────────────────────────────────────────────────────────
echo ""
echo "--- [1/5] k3d cluster ---"
if ! k3d cluster list 2>/dev/null | grep -q "^$CLUSTER"; then
    k3d cluster create "$CLUSTER" \
        --agents 2 \
        --port "80:80@loadbalancer" \
        --port "443:443@loadbalancer"
else
    echo "Cluster '$CLUSTER' already running."
fi
kubectl config use-context "k3d-$CLUSTER"

kubectl create namespace "$ARGOCD_NS" --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace "$APP_NS"    --dry-run=client -o yaml | kubectl apply -f -

# ── 2. Sealed Secrets controller ──────────────────────────────────────────────
echo ""
echo "--- [2/5] Sealed Secrets controller ---"
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets --force-update >/dev/null
helm repo update sealed-secrets >/dev/null
helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
    --namespace kube-system \
    --wait --timeout 2m

# ── 3. Apply sealed secrets ───────────────────────────────────────────────────
echo ""
echo "--- [3/5] Sealed secrets ---"
kubectl apply -f gitops/secrets/ghcr-docker-config.sealed.yaml
kubectl apply -f gitops/secrets/dockerhub-pull-secret.sealed.yaml

echo "Waiting for controller to decrypt..."
for secret in "ghcr-docker-config:$ARGOCD_NS" "dockerhub-pull-secret:$APP_NS"; do
    name="${secret%%:*}"
    ns="${secret##*:}"
    until kubectl get secret "$name" -n "$ns" &>/dev/null; do
        sleep 2
    done
    echo "  Decrypted: $name ($ns)"
done

# ── 4. ArgoCD ─────────────────────────────────────────────────────────────────
echo ""
echo "--- [4/5] ArgoCD ---"
helm repo add argo https://argoproj.github.io/argo-helm --force-update >/dev/null
helm repo update argo >/dev/null
helm upgrade --install argocd argo/argo-cd \
    --namespace "$ARGOCD_NS" \
    --values infrastructure/local/argocd/values.yaml \
    --wait --timeout 5m

# ── 5. Application CRD ────────────────────────────────────────────────────────
echo ""
echo "--- [5/5] ArgoCD Application ---"
kubectl apply -f gitops/application.yaml

echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "ArgoCD sync status:"
kubectl get application bsc-devops -n "$ARGOCD_NS" 2>/dev/null || echo "  (syncing...)"
echo ""
echo "Pod status (may still be starting):"
kubectl get pods -n "$APP_NS" 2>/dev/null || true
echo ""
echo "ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n $ARGOCD_NS 8080:80"
echo "  open http://localhost:8080"
echo ""
echo "Initial admin password:"
echo "  kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NS \\"
echo "    -o jsonpath='{.data.password}' | base64 -d && echo"
