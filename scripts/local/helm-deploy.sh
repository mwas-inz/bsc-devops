#!/bin/bash
# Usage: bash scripts/local/helm-deploy.sh [IMAGE_TAG]
# IMAGE_TAG defaults to the current git commit SHA (must be pushed to Docker Hub by CI).
set -euo pipefail

RELEASE="bsc-devops"
NAMESPACE="bsc-devops"
CHART="infrastructure/helm/bsc-devops"
CLUSTER="bsc-devops"
TAG="${1:-$(git rev-parse HEAD)}"

echo "=== BSC DevOps — Helm Deployment ==="
echo "Release:   $RELEASE"
echo "Namespace: $NAMESPACE"
echo "Image tag: $TAG"

if ! command -v k3d &>/dev/null; then
    echo "ERROR: k3d not found. Install it first: https://k3d.io/stable/#installation"
    exit 1
fi

if ! command -v helm &>/dev/null; then
    echo "ERROR: helm not found. Install it first: https://helm.sh/docs/intro/install/"
    exit 1
fi

if ! k3d cluster list 2>/dev/null | grep -q "^$CLUSTER"; then
    echo "Creating k3d cluster '$CLUSTER'..."
    k3d cluster create "$CLUSTER" \
        --agents 2 \
        --port "80:80@loadbalancer" \
        --port "443:443@loadbalancer"
fi

kubectl config use-context "k3d-$CLUSTER"

echo ""
echo "--- helm upgrade --install ---"
helm upgrade --install "$RELEASE" "$CHART" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --set imageTag="$TAG" \
    --wait \
    --timeout 5m

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Pod status:"
kubectl get pods -n "$NAMESPACE"
echo ""
echo "Access:"
echo "  Frontend:  http://localhost"
echo "  Jaeger UI: kubectl port-forward svc/jaeger 16686:16686 -n $NAMESPACE"
echo "             then open http://localhost:16686"
echo ""
echo "Helm commands:"
echo "  helm status $RELEASE -n $NAMESPACE"
echo "  helm history $RELEASE -n $NAMESPACE"
echo "  helm rollback $RELEASE -n $NAMESPACE"
echo ""
echo "Debug commands:"
echo "  kubectl logs -f deployment/users -n $NAMESPACE"
echo "  kubectl logs -f deployment/tasks -n $NAMESPACE"
echo "  kubectl port-forward svc/users 8080:8080 -n $NAMESPACE"
echo "  kubectl port-forward svc/tasks 8080:8080 -n $NAMESPACE"
