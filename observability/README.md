# Observability

Observability strategy for the thesis platform based on the three-pillar model
(metrics, logs, traces).

## Adopted Decisions

- **ADR-0006** — OpenTelemetry as the unified observability standard. All services export
  traces and metrics via the OpenTelemetry SDK.
- **ADR-0007** — LGTM stack (Loki, Grafana, Tempo, Prometheus) as the observability backend.

## Current State

Jaeger is deployed as the tracing backend in the Helm chart
(`infrastructure/helm/bsc-devops/templates/jaeger.yaml`) for local development.
Application services export OpenTelemetry traces to Jaeger and Prometheus-format metrics
via Micrometer.

The production LGTM stack (Loki, Grafana, Tempo, Prometheus) is planned for a later sprint
once cluster resource requirements are validated.

## Tech Cards

Reference cards for observability components are in `docs/tech-card/`:
`grafana.md`, `loki.md`, `opentelemetry-collector.md`, `prometheus.md`, `tempo.md`.
