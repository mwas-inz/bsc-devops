#!/bin/bash
# Usage: bash gitops/argocd/install.sh
#
# Bootstraps the full GitOps stack on a local k3d cluster:
#   1. k3d cluster (if not already running)
#   2. Sealed Secrets controller  — decrypts gitops/secrets/*.sealed.yaml
#   3. Sealed Secrets applied     — GHCR Docker config + Docker Hub pull secret
#   4. ArgoCD                     — uses ghcr-docker-config to pull Helm chart
#   5. ArgoCD Application CRD     — triggers automated sync of bsc-devops chart
#
# No tokens required at runtime. All credentials are pre-sealed in Git.
set -euo pipefail

CLUSTER="bsc-devops"
ARGOCD_NAMESPACE="argocd"
APP_NAMESPACE="bsc-devops"

echo "=== BSC DevOps — GitOps Bootstrap ==="

for cmd in kubectl helm k3d kubeseal; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd not found."
        exit 1
    fi
done

# ── 1. Cluster ────────────────────────────────────────────────────────────────
if ! k3d cluster list 2>/dev/null | grep -q "^$CLUSTER"; then
    echo ""
    echo "--- Creating k3d cluster '$CLUSTER' ---"
    k3d cluster create "$CLUSTER" \
        --agents 2 \
        --port "80:80@loadbalancer" \
        --port "443:443@loadbalancer"
fi
kubectl config use-context "k3d-$CLUSTER"

kubectl create namespace "$ARGOCD_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace "$APP_NAMESPACE"    --dry-run=client -o yaml | kubectl apply -f -

# ── 2. Sealed Secrets controller ──────────────────────────────────────────────
echo ""
echo "--- Installing Sealed Secrets controller ---"
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets --force-update >/dev/null
helm repo update sealed-secrets >/dev/null
helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
    --namespace kube-system \
    --wait --timeout 2m

# ── 3. Apply sealed credentials ───────────────────────────────────────────────
echo ""
echo "--- Applying sealed secrets ---"
kubectl apply -f gitops/secrets/ghcr-docker-config.sealed.yaml
kubectl apply -f gitops/secrets/dockerhub-pull-secret.sealed.yaml

echo "Waiting for Sealed Secrets controller to decrypt..."
kubectl wait secret/ghcr-docker-config \
    -n "$ARGOCD_NAMESPACE" --for=jsonpath='{.data}' --timeout=30s 2>/dev/null \
    || sleep 10   # fallback: controller may need a moment on cold start

# ── 4. ArgoCD ─────────────────────────────────────────────────────────────────
echo ""
echo "--- Installing ArgoCD ---"
helm repo add argo https://argoproj.github.io/argo-helm --force-update >/dev/null
helm repo update argo >/dev/null
helm upgrade --install argocd argo/argo-cd \
    --namespace "$ARGOCD_NAMESPACE" \
    --values infrastructure/local/argocd/values.yaml \
    --wait --timeout 5m

# ── 5. Application CRD ────────────────────────────────────────────────────────
echo ""
echo "--- Applying ArgoCD Application ---"
kubectl apply -f gitops/application.yaml

echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "ArgoCD UI (port-forward):"
echo "  kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:80"
echo "  then open http://localhost:8080"
echo ""
echo "Initial admin password:"
echo "  kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NAMESPACE \\"
echo "    -o jsonpath='{.data.password}' | base64 -d && echo"
echo ""
echo "App sync status:"
echo "  kubectl get application bsc-devops -n $ARGOCD_NAMESPACE"
echo "  kubectl get pods -n $APP_NAMESPACE"
