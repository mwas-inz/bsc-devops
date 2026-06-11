# Docs

Shared documentation assets for the repository.

## Architecture Decision Records

`docs/adr/` contains 16 MADR-format ADRs covering all major technology choices:

- Runtime (Kubernetes, k3d), language (Java/JVM), build system (Gradle)
- Containerisation (Dockerfile, Trivy scanning, Cosign keyless signing)
- Observability (OpenTelemetry, LGTM stack)
- Delivery (Helm, ArgoCD, Sealed Secrets)
- Frontend (Vue 3)
- Version control (Conventional Commits, GitHub)

See [docs/adr/README.md](adr/README.md) for the full index.

## Tech Cards

`docs/tech-card/` contains 13 one-page reference cards for each adopted technology:
ArgoCD, Docker, Grafana, Helm, k3d, Kubernetes, Loki, OpenTelemetry Collector, Prometheus,
Quarkus, Sealed Secrets, Tempo, Vue.

## Diagrams

`docs/diagrams/` is reserved for shared architecture and flow diagrams referenced by the thesis
and ADRs. Diagram creation is pending.
