#!/bin/bash
# Usage: bash scripts/local/helm-deploy.sh [IMAGE_TAG]
# IMAGE_TAG defaults to the current git commit SHA (must be pushed to Docker Hub by CI).
set -euo pipefail

RELEASE="bsc-devops"
NAMESPACE="bsc-devops"
CHART="infrastructure/helm/bsc-devops"
TAG="${1:-$(git rev-parse HEAD)}"

echo "=== BSC DevOps — Helm Deployment ==="
echo "Release:   $RELEASE"
echo "Namespace: $NAMESPACE"
echo "Image tag: $TAG"

if ! command -v minikube &>/dev/null; then
    echo "ERROR: minikube not found. Install it first: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

if ! command -v helm &>/dev/null; then
    echo "ERROR: helm not found. Install it first: https://helm.sh/docs/intro/install/"
    exit 1
fi

if ! minikube status --format='{{.Host}}' 2>/dev/null | grep -q "Running"; then
    echo "Starting minikube (4 CPUs, 4GB RAM)..."
    minikube start --memory=4096 --cpus=4
fi

echo ""
echo "Enabling ingress addon..."
minikube addons enable ingress

echo ""
echo "--- helm upgrade --install ---"
helm upgrade --install "$RELEASE" "$CHART" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --set imageTag="$TAG" \
    --wait \
    --timeout 5m

DRIVER=$(minikube profile list --output=json 2>/dev/null | grep -o '"Driver":"[^"]*"' | head -1 | cut -d'"' -f4)
echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Pod status:"
kubectl get pods -n "$NAMESPACE"
echo ""
echo "Access:"
if [ "$DRIVER" = "docker" ]; then
    echo "  Docker driver detected — minikube ip is not reachable from the host."
    echo "  Run in a separate terminal:  minikube tunnel"
    echo "  Then open:                   http://localhost"
else
    MINIKUBE_IP=$(minikube ip)
    echo "  Frontend:  http://$MINIKUBE_IP"
fi
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
