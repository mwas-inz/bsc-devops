#!/bin/bash
# Usage: bash scripts/local/measure-resources.sh [output-dir]
#
# Measures CPU and memory of every pod in the local k3d cluster in two phases:
#   1. idle  — IDLE_SAMPLES snapshots of `kubectl top`, no traffic,
#   2. load  — snapshots taken while scripts/local/load-test.js runs in the
#              grafana/k6 container against Traefik (via the k3d load balancer).
# Produces raw samples (CSV), the k6 summary and a per-pod peak table.
#
# Prerequisites: kubectl pointed at the local k3d cluster (metrics-server is
# bundled with k3s), Docker running.
set -euo pipefail

OUT="${1:-./resource-usage-$(date +%Y%m%d-%H%M%S)}"
INTERVAL=15
IDLE_SAMPLES=8
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$OUT"

# Append one `kubectl top` snapshot as CSV: phase,namespace,pod,cpu_m,mem_mi
sample() {
    kubectl top pods -A --no-headers | awk -v phase="$1" \
        '{ gsub("m","",$3); gsub("Mi","",$4); print phase","$1","$2","$3","$4 }' \
        >> "$OUT/samples.csv"
}

echo "phase,namespace,pod,cpu_m,mem_mi" > "$OUT/samples.csv"

echo "== Idle phase: $IDLE_SAMPLES samples every ${INTERVAL}s"
for _ in $(seq "$IDLE_SAMPLES"); do
    sample idle
    sleep "$INTERVAL"
done

echo "== Load phase: k6 running"
# k6 joins the k3d Docker network and targets the cluster load balancer directly,
# so no host DNS/port mapping is involved. The script is passed on stdin — avoids
# host-path translation of volume mounts on Windows.
docker run --rm -i --network k3d-bsc-devops -e BASE_URL=http://k3d-bsc-devops-serverlb \
    grafana/k6 run -q - < "$SCRIPT_DIR/load-test.js" \
    > "$OUT/k6-summary.txt" 2>&1 &
K6_PID=$!
while kill -0 "$K6_PID" 2>/dev/null; do
    sample load
    sleep "$INTERVAL"
done
wait "$K6_PID" || echo "k6 thresholds failed — see $OUT/k6-summary.txt"

echo "== Peak usage per pod (idle max / load max)"
{
    printf "%-60s %10s %10s %10s %10s\n" "POD" "IDLE_CPU" "LOAD_CPU" "IDLE_MEM" "LOAD_MEM"
    awk -F, 'NR > 1 {
            key = $2"/"$3
            if ($4 + 0 > cpu[$1,key]) cpu[$1,key] = $4 + 0
            if ($5 + 0 > mem[$1,key]) mem[$1,key] = $5 + 0
            pods[key] = 1
        }
        END {
            for (p in pods)
                printf "%-60s %9dm %9dm %8dMi %8dMi\n", p, cpu["idle",p], cpu["load",p], mem["idle",p], mem["load",p]
        }' "$OUT/samples.csv" | sort
} | tee "$OUT/peaks.txt"

echo "Results in $OUT"
