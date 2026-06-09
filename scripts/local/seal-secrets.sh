#!/bin/bash
# Usage: bash scripts/local/seal-secrets.sh
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
set -euo pipefail

CLUSTER="bsc-devops"
GHCR_USER="mwas-inz"
DOCKERHUB_USER="mateuszwas"

echo "=== BSC DevOps — Seal Secrets ==="

# ── Prerequisites ─────────────────────────────────────────────────────────────
for cmd in kubectl helm k3d kubeseal; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd not found."
        exit 1
    fi
done

if [[ -z "${GHCR_TOKEN:-}" ]]; then
    echo "ERROR: GHCR_TOKEN is not set."
    exit 1
fi
if [[ -z "${ARGO_DOCKERHUB_TOKEN:-}" ]]; then
    echo "ERROR: ARGO_DOCKERHUB_TOKEN is not set."
    exit 1
fi

# ── Cluster + Sealed Secrets controller ───────────────────────────────────────
if ! k3d cluster list 2>/dev/null | grep -q "^$CLUSTER"; then
    echo "Creating k3d cluster '$CLUSTER'..."
    k3d cluster create "$CLUSTER" \
        --agents 2 \
        --port "80:80@loadbalancer" \
        --port "443:443@loadbalancer"
fi
kubectl config use-context "k3d-$CLUSTER"

if ! helm status sealed-secrets -n kube-system &>/dev/null; then
    echo "Installing Sealed Secrets controller..."
    helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets --force-update >/dev/null
    helm repo update sealed-secrets >/dev/null
    helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
        --namespace kube-system \
        --wait --timeout 2m
else
    echo "Sealed Secrets controller already installed."
fi

# ── Target namespaces (kubeseal encodes namespace into ciphertext) ─────────────
kubectl create namespace argocd     --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace bsc-devops --dry-run=client -o yaml | kubectl apply -f -

mkdir -p gitops/secrets

# ── Seal GHCR Docker config (argocd namespace) ────────────────────────────────
echo ""
echo "--- Sealing GHCR Docker config (namespace: argocd) ---"
DOCKER_AUTH=$(echo -n "${GHCR_USER}:${GHCR_TOKEN}" | base64 -w0)
DOCKER_CONFIG_JSON=$(printf '{"auths":{"ghcr.io":{"auth":"%s"}}}' "$DOCKER_AUTH")

kubectl create secret generic ghcr-docker-config \
    --namespace argocd \
    --from-literal=config.json="$DOCKER_CONFIG_JSON" \
    --dry-run=client -o yaml \
| kubeseal \
    --controller-namespace kube-system \
    --controller-name sealed-secrets \
    --format yaml \
    > gitops/secrets/ghcr-docker-config.sealed.yaml

echo "Written: gitops/secrets/ghcr-docker-config.sealed.yaml"

# ── Seal Docker Hub pull secret (bsc-devops namespace) ────────────────────────
echo ""
echo "--- Sealing Docker Hub pull secret (namespace: bsc-devops) ---"
kubectl create secret docker-registry dockerhub-pull-secret \
    --namespace bsc-devops \
    --docker-server=docker.io \
    --docker-username="$DOCKERHUB_USER" \
    --docker-password="$ARGO_DOCKERHUB_TOKEN" \
    --dry-run=client -o yaml \
| kubeseal \
    --controller-namespace kube-system \
    --controller-name sealed-secrets \
    --format yaml \
    > gitops/secrets/dockerhub-pull-secret.sealed.yaml

echo "Written: gitops/secrets/dockerhub-pull-secret.sealed.yaml"

echo ""
echo "=== Sealing Complete ==="
echo ""
echo "Commit the sealed files to Git:"
echo "  git add gitops/secrets/"
echo "  git commit -m 'chore(gitops): rotate sealed secrets'"
echo ""
echo "WARNING: These sealed files are bound to the Sealed Secrets controller"
echo "key in cluster '$CLUSTER'. If the cluster is recreated, re-run this"
echo "script to re-seal with the new key."
echo ""
echo "Back up the controller key to survive cluster deletion:"
echo "  kubectl get secret -n kube-system \\"
echo "    -l sealedsecrets.bitnami.com/sealed-secrets-key \\"
echo "    -o yaml > gitops/secrets/sealed-secrets-key.backup.yaml"
echo "  # DO NOT commit the key backup to Git."
