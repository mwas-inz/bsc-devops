#!/bin/bash
# Usage: bash scripts/local/ui-credentials.sh
#
# Prints address, user, and password for every local UI served by Traefik.
# Values are read live from Kubernetes Secrets — nothing is stored in the repo.
#
# Prerequisites: kubectl pointed at the local k3d cluster.
set -euo pipefail

# Read one key from a Secret; print a placeholder when the Secret is missing so
# a single absent secret does not abort the whole listing.
secret_value() {
    local ns="$1" name="$2" key="$3" value
    if ! value=$(kubectl -n "$ns" get secret "$name" \
        -o jsonpath="{.data.$key}" 2>/dev/null | base64 -d); then
        value="<secret $ns/$name not found>"
    fi
    echo "$value"
}

ARGOCD_PASS=$(secret_value argocd argocd-initial-admin-secret password)
GRAFANA_USER=$(secret_value observability grafana-admin admin-user)
GRAFANA_PASS=$(secret_value observability grafana-admin admin-password)

echo "=== BSC DevOps — Local UI Credentials ==="
echo ""
printf '%-12s %-30s %-10s %s\n' "SERVICE" "ADDRESS" "USER" "PASSWORD"
printf '%-12s %-30s %-10s %s\n' \
    "ArgoCD" "http://argocd.localhost" "admin" "$ARGOCD_PASS" \
    "Grafana" "http://grafana.localhost" "$GRAFANA_USER" "$GRAFANA_PASS" \
    "Prometheus" "http://prometheus.localhost" "-" "no auth" \
    "Loki API" "http://loki.localhost" "-" "no auth" \
    "Demo app" "http://localhost/" "-" "no auth"
