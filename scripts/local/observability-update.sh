#!/bin/bash
# Usage: bash scripts/local/observability-update.sh [version]
#   e.g. bash scripts/local/observability-update.sh          # re-apply + hard refresh only
#        bash scripts/local/observability-update.sh 0.3.0    # bump targetRevision first
#
# Pushes the desired state of the observability ArgoCD Application to the local
# cluster. With a version argument it first bumps targetRevision in
# gitops/observability.yaml and commits the change (mirror of argocd-update.sh
# for the apps chart). Without one it re-applies the manifest as committed —
# useful when the pinned chart version changed in Git but the live Application
# still points at an older one.
#
# A hard refresh is forced so ArgoCD re-pulls the OCI chart from GHCR instead of
# waiting for its reconciliation interval. The script ends by probing the
# Traefik ingress hostnames so the UI exposure can be verified end to end:
#   grafana.localhost / prometheus.localhost / loki.localhost
#
# Prerequisites: kubectl pointed at the local k3d cluster, ArgoCD running.
set -euo pipefail

VERSION="${1:-}"
APP_FILE="gitops/observability.yaml"
ARGOCD_NS="argocd"
APP_NAME="observability"
OBS_NS="observability"

echo "=== BSC DevOps — Observability Application Update ==="

# ── Prerequisites ─────────────────────────────────────────────────────────────
for cmd in kubectl curl sed git; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd not found."
        exit 1
    fi
done

if [[ ! -f "$APP_FILE" ]]; then
    echo "ERROR: $APP_FILE not found. Run from repository root."
    exit 1
fi

# ── Optional: bump targetRevision ─────────────────────────────────────────────
CURRENT=$(grep 'targetRevision' "$APP_FILE" | awk '{print $2}' | tr -d '"')
if [[ -n "$VERSION" && "$VERSION" != "$CURRENT" ]]; then
    echo ""
    echo "--- Updating targetRevision: $CURRENT → $VERSION ---"
    sed -i "s/targetRevision: .*/targetRevision: \"$VERSION\"/" "$APP_FILE"

    echo ""
    echo "--- Committing to Git ---"
    git add "$APP_FILE"
    git commit -m "chore(gitops): bump observability targetRevision to $VERSION"
    git push
else
    echo "Target version: $CURRENT (no bump requested)"
fi

# ── Apply and hard-refresh ────────────────────────────────────────────────────
echo ""
echo "--- Applying Application and forcing a hard refresh ---"
kubectl apply -f "$APP_FILE"
kubectl -n "$ARGOCD_NS" annotate application "$APP_NAME" \
    argocd.argoproj.io/refresh=hard --overwrite >/dev/null

# The refresh annotation is consumed asynchronously: ArgoCD removes it once the
# re-render is done. Waiting for its removal prevents the Synced/Healthy checks
# below from passing against stale pre-refresh status.
echo "Waiting for ArgoCD to process the refresh..."
for _ in $(seq 1 60); do
    PENDING=$(kubectl -n "$ARGOCD_NS" get application "$APP_NAME" \
        -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/refresh}')
    [[ -z "$PENDING" ]] && break
    sleep 2
done
if [[ -n "$PENDING" ]]; then
    echo "ERROR: ArgoCD did not process the hard refresh within 120s."
    exit 1
fi

echo ""
echo "--- Waiting for the Application to be Synced and Healthy ---"
kubectl -n "$ARGOCD_NS" wait --for=jsonpath='{.status.sync.status}'=Synced \
    "application/$APP_NAME" --timeout=300s
kubectl -n "$ARGOCD_NS" wait --for=jsonpath='{.status.health.status}'=Healthy \
    "application/$APP_NAME" --timeout=300s

# ── Verify ingress hostnames ──────────────────────────────────────────────────
echo ""
echo "--- Ingresses delivered by the chart ---"
kubectl -n "$OBS_NS" get ingress

echo ""
echo "--- Probing hostnames through Traefik ---"
# k3d maps localhost:80 to Traefik; --resolve pins *.localhost to loopback so
# the probe does not depend on the OS resolver handling RFC 6761 subdomains.
# Probes assert on the response body, not the status code: the apps chart ships
# a catch-all (host: *) frontend ingress that answers 200 for ANY hostname, so
# an HTTP 200 alone does not prove the observability route exists.
CHECKS=(
    "grafana.localhost|/api/health|\"database\": *\"ok\""
    "prometheus.localhost|/-/ready|Prometheus Server is Ready"
    "loki.localhost|/ready|^ready$"
)
FAILED=0
for entry in "${CHECKS[@]}"; do
    IFS='|' read -r host path marker <<<"$entry"
    ok=0
    for _ in $(seq 1 15); do
        if curl -s --resolve "${host}:80:127.0.0.1" "http://${host}${path}" \
            | grep -Eq "$marker"; then
            ok=1
            break
        fi
        sleep 2
    done
    if [[ "$ok" == "1" ]]; then
        echo "OK   http://${host}${path}"
    else
        echo "FAIL http://${host}${path} (expected body matching: $marker)"
        FAILED=1
    fi
done

echo ""
if [[ "$FAILED" -ne 0 ]]; then
    echo "=== Update applied, but some hostnames are not reachable ==="
    exit 1
fi
echo "=== Update Applied — observability UIs reachable via Traefik ==="
