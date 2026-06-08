#!/bin/bash
# Usage: bash scripts/local/deploy-k3d.sh [IMAGE_TAG]
# IMAGE_TAG defaults to the current git commit SHA (must be pushed to Docker Hub by CI).
set -euo pipefail

NAMESPACE="bsc-devops"
CLUSTER="bsc-devops"
INFRA="infrastructure/local"
TAG="${1:-$(git rev-parse HEAD)}"

echo "=== BSC DevOps — k3d Deployment ==="
echo "Image tag: $TAG"

if ! command -v k3d &>/dev/null; then
    echo "ERROR: k3d not found. Install it first: https://k3d.io/stable/#installation"
    exit 1
fi

if ! k3d cluster list 2>/dev/null | grep -q "^$CLUSTER"; then
    echo "Creating k3d cluster '$CLUSTER'..."
    k3d cluster create "$CLUSTER" \
        --agents 1 \
        --port "80:80@loadbalancer" \
        --port "443:443@loadbalancer"
fi

kubectl config use-context "k3d-$CLUSTER"

# Applies a manifest file after substituting IMAGE_TAG with $TAG.
kapply() {
    sed "s/IMAGE_TAG/$TAG/g" "$1" | kubectl apply -f -
}

echo ""
echo "--- Namespace ---"
kubectl apply -f "$INFRA/namespace.yaml"

echo ""
echo "--- Postgres ---"
kubectl apply -f "$INFRA/postgres/postgres-configmap.yaml"
kubectl apply -f "$INFRA/postgres/postgres-pvc.yaml"
kubectl apply -f "$INFRA/postgres/postgres-deployment.yaml"
kubectl apply -f "$INFRA/postgres/postgres-service.yaml"

echo ""
echo "--- Pulsar ---"
kubectl apply -f "$INFRA/pulsar/pulsar-deployment.yaml"
kubectl apply -f "$INFRA/pulsar/pulsar-service.yaml"

echo ""
echo "--- Jaeger ---"
kubectl apply -f "$INFRA/jaeger/jaeger-deployment.yaml"
kubectl apply -f "$INFRA/jaeger/jaeger-service.yaml"

echo ""
echo "Waiting for Postgres..."
kubectl rollout status deployment/postgres -n "$NAMESPACE" --timeout=120s

echo "Waiting for Pulsar (may take ~2 minutes)..."
kubectl rollout status deployment/pulsar -n "$NAMESPACE" --timeout=300s

echo ""
echo "--- App config and secrets ---"
kubectl apply -f "$INFRA/apps/db-secret.yaml"
kubectl apply -f "$INFRA/apps/app-config.yaml"

echo ""
echo "--- Applications ---"
kapply "$INFRA/apps/users-deployment.yaml"
kapply "$INFRA/apps/tasks-deployment.yaml"
kapply "$INFRA/apps/task-archiver-deployment.yaml"

echo ""
echo "--- Frontend ---"
kapply "apps/frontend/kubernetes.yml"

echo ""
echo "Waiting for applications..."
kubectl rollout status deployment/users -n "$NAMESPACE" --timeout=120s
kubectl rollout status deployment/tasks -n "$NAMESPACE" --timeout=120s
kubectl rollout status deployment/task-archiver -n "$NAMESPACE" --timeout=120s
kubectl rollout status deployment/frontend -n "$NAMESPACE" --timeout=120s

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
echo "Debug commands:"
echo "  kubectl logs -f deployment/users -n $NAMESPACE"
echo "  kubectl logs -f deployment/tasks -n $NAMESPACE"
echo "  kubectl port-forward svc/users 8080:8080 -n $NAMESPACE"
echo "  kubectl port-forward svc/tasks 8080:8080 -n $NAMESPACE"
