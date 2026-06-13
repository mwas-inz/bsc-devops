#!/bin/bash
# Observability rollout — applies the Etap Monitor stack to the cluster.
#
# CI/CD publishes the Helm charts and the application images; this script does NOT tag
# or build anything. It only performs the in-cluster steps: sync the bsc-devops app and
# deliver the LGTM + Collector stack via ArgoCD. Run once the charts are published.
#
# Usage: bash scripts/local/observability-rollout.sh
set -euo pipefail

OBS_NS="observability"

echo "--- [1/4] bsc-devops: sync the published chart (apps -> Collector, Jaeger gone) ---"
# targetRevision 0.7.0 is already committed; re-apply so the live app adopts it.
kubectl apply -f gitops/application.yaml
kubectl -n argocd annotate application bsc-devops \
  argocd.argoproj.io/refresh=hard --overwrite >/dev/null

echo "--- [2/4] Grafana admin secret (sealed, replaces the dev secret) ---"
kubectl create namespace "$OBS_NS" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n "$OBS_NS" delete secret grafana-admin --ignore-not-found
kubectl apply -f gitops/secrets/grafana-admin.sealed.yaml
# Wait for the Sealed Secrets controller to decrypt it.
until kubectl -n "$OBS_NS" get secret grafana-admin >/dev/null 2>&1; do sleep 2; done

echo "--- [3/4] Deliver the LGTM + Collector stack via ArgoCD ---"
kubectl apply -f gitops/observability-application.yaml

echo "--- [4/4] Wait for the stack to be healthy ---"
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy \
  application/observability --timeout=300s || true
kubectl -n "$OBS_NS" get pods

cat <<'NEXT'

Verify correlation in Grafana:
  PW=$(kubectl -n observability get secret grafana-admin -o jsonpath='{.data.admin-password}' | base64 -d)
  kubectl -n observability port-forward svc/grafana 3000:80    # login: admin / $PW
  Explore -> Tempo -> open a trace -> "Logs for this span"     # Tempo -> Loki by trace_id
NEXT
