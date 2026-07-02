# Observability

Observability strategy for the thesis platform based on the three-pillar model
(metrics, logs, traces).

## Adopted Decisions

- **ADR-0006** — OpenTelemetry as the unified observability standard. All services export
  traces and metrics via the OpenTelemetry SDK.
- **ADR-0007** — LGTM stack (Loki, Grafana, Tempo, Prometheus) as the observability backend.

## Current State

The LGTM stack (Loki, Grafana, Tempo, Prometheus) and an OpenTelemetry Collector are
deployed via `infrastructure/helm/observability/` and delivered by a dedicated ArgoCD
Application (`gitops/observability.yaml`). Application services export OTLP
traces and logs to the Collector, which fans them out to Tempo and Loki; Prometheus
scrapes application metrics directly from `/q/metrics`. Jaeger has been retired in
favour of Tempo.

## Tech Cards

Reference cards for observability components are in `docs/tech-card/`:
`grafana.md`, `loki.md`, `opentelemetry-collector.md`, `prometheus.md`, `tempo.md`.
