# Observability Stack (LGTM)

Umbrella Helm chart that deploys the LGTM observability backend into the
`observability` namespace, bundling the official Grafana and Prometheus community
charts as pinned dependencies (ADR-0006, ADR-0007).

| Component | Chart | Role | In-cluster endpoint |
| --- | --- | --- | --- |
| Loki | `grafana/loki` 7.0.0 | Logs | `http://loki:3100` |
| Tempo | `grafana/tempo` 1.24.4 | Traces | OTLP `tempo:4317` / `tempo:4318`, query `http://tempo:3200` |
| Grafana | `grafana/grafana` 10.5.15 | Visualization | `http://grafana` (admin; password in `grafana-admin` Secret) |
| Prometheus | `prometheus-community/prometheus` 29.10.1 | Metrics | `http://prometheus` |
| OTel Collector | in-chart (contrib 0.154.0) | OTLP gateway → Loki/Tempo | OTLP `otel-collector:4317` / `:4318` |

## Design notes (single-node k3d)

- **Loki** runs in `SingleBinary` mode with filesystem storage on a small
  `local-path` PVC (its container has a read-only root fs, so `/var/loki` needs a
  writable volume). The memcached caches and nginx gateway are disabled.
- **Prometheus** is the server only — node-exporter and kube-state-metrics are
  disabled per the "lean" decision (ADR-0007); it scrapes the application pods via
  their existing `prometheus.io/scrape` annotations.
- **Tempo** and **Grafana** are ephemeral (no persistence). Tempo enables the OTLP
  receiver by default.
- **OTel Collector** is a single-Deployment gateway (config in
  `files/otel-collector-config.yaml`): applications send OTLP traces and logs to it,
  and it fans them out to Tempo and Loki. Metrics bypass it — Prometheus scrapes the
  apps directly. The legacy `loki` exporter is avoided in favour of OTLP to Loki's
  native `/otlp` endpoint.
- **Datasources** (Prometheus/Loki/Tempo, with cross-pillar correlation —
  Loki→Tempo `derivedFields`, Tempo→Loki `tracesToLogsV2`, Tempo→Prometheus
  `serviceMap`) are provisioned via `grafana.datasources`. **Dashboards** under
  `files/dashboards/` are auto-imported by the Grafana sidecar (INZ-26).

## Deploy locally

```sh
# Grafana admin credentials are read from a Secret (never committed). Create it
# with a random password before installing:
kubectl create namespace observability --dry-run=client -o yaml | kubectl apply -f -
kubectl -n observability create secret generic grafana-admin \
  --from-literal=admin-user=admin \
  --from-literal=admin-password="$(openssl rand -hex 16)"

helm dependency build infrastructure/helm/observability
helm install observability infrastructure/helm/observability \
  -n observability --create-namespace
```

In the cluster the stack is delivered as an ArgoCD Application (INZ-21, Stage 5).
