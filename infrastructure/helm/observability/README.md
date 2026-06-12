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

## Design notes (single-node k3d)

- **Loki** runs in `SingleBinary` mode with filesystem storage on a small
  `local-path` PVC (its container has a read-only root fs, so `/var/loki` needs a
  writable volume). The memcached caches and nginx gateway are disabled.
- **Prometheus** is the server only — node-exporter and kube-state-metrics are
  disabled per the "lean" decision (ADR-0007); it scrapes the application pods via
  their existing `prometheus.io/scrape` annotations.
- **Tempo** and **Grafana** are ephemeral (no persistence). Tempo enables the OTLP
  receiver by default.
- Datasources and dashboards are provisioned as code separately (INZ-26).

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
