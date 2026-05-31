#!/bin/bash
# Usage: bash scripts/local/deploy-minikube.sh [IMAGE_TAG]
# IMAGE_TAG defaults to the current git commit SHA (must be pushed to Docker Hub by CI).
set -euo pipefail

NAMESPACE="bsc-devops"
INFRA="infrastructure/local"
TAG="${1:-$(git rev-parse HEAD)}"

echo "=== BSC DevOps — Minikube Deployment ==="
echo "Image tag: $TAG"

if ! command -v minikube &>/dev/null; then
    echo "ERROR: minikube not found. Install it first: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

if ! minikube status --format='{{.Host}}' 2>/dev/null | grep -q "Running"; then
    echo "Starting minikube (4 CPUs, 4GB RAM)..."
    minikube start --memory=4096 --cpus=4
fi

echo ""
echo "Enabling ingress addon..."
minikube addons enable ingress

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
kubectl apply -f "$INFRA/postgres/postgres-pv.yaml"
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

MINIKUBE_IP=$(minikube ip)
echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Pod status:"
kubectl get pods -n "$NAMESPACE"
echo ""
echo "Access:"
echo "  Frontend:  http://$MINIKUBE_IP"
echo "  Jaeger UI: kubectl port-forward svc/jaeger 16686:16686 -n $NAMESPACE"
echo "             then open http://localhost:16686"
echo ""
echo "Debug commands:"
echo "  kubectl logs -f deployment/users -n $NAMESPACE"
echo "  kubectl logs -f deployment/tasks -n $NAMESPACE"
echo "  kubectl port-forward svc/users 8080:8080 -n $NAMESPACE"
echo "  kubectl port-forward svc/tasks 8081:8081 -n $NAMESPACE"
