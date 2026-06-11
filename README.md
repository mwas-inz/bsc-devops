# bsc-devops

Monorepository for an engineering thesis on modern DevOps and cloud-native SDLC practices.

This repository combines Java application development, infrastructure as code, technical documentation, and thesis assets in one structure.

## Core Principles

- **ADR First**: Major architectural changes must be documented in `docs/adr/`.
- **Java Excellence**: Apply SOLID principles; keep code well-structured and maintainable.
- **Cloud Native & DevOps**: Design for observability, scalability, and portability; follow 12-factor application practices.
- **Academic Rigor**: Keep thesis language formal and align implementation details with thesis descriptions.

## Repository Structure

- `apps/` — three Quarkus microservices (`users`, `tasks`, `task-archiver`) and a Vue 3 frontend
- `infrastructure/` — Helm umbrella chart (v0.6.0) and local Kubernetes manifests
- `docs/adr/` — 16 architecture decision records (MADR format)
- `docs/tech-card/` — 13 technology reference cards
- `docs/diagrams/` — shared architecture and flow diagrams (planned)
- `.github/workflows/` — GitHub Actions CI/CD (per-service CI, Helm CD, release signing, thesis PDF)
- `gitops/` — ArgoCD Application manifest and Sealed Secrets for cluster bootstrap
- `observability/` — observability strategy notes
- `thesis/` — LaTeX thesis source, bibliography, and compilation scripts
- `scripts/` — developer workflow scripts (local cluster, GitOps bootstrap, thesis compilation)

## Status

Three Quarkus microservices (`users`, `tasks`, `task-archiver`) and a Vue 3 frontend are built,
containerised, and published to GHCR.
A Helm umbrella chart (v0.6.0) packages all services and is published via the `cd-helm` workflow.
A GitOps bootstrap script provisions a k3d cluster, installs Sealed Secrets and ArgoCD, and lets
ArgoCD reconcile the chart from GHCR.
GitHub Actions provides per-service CI (build, test, Trivy image scan, Cosign keyless signing),
Helm lint/validate, and automated chart tagging.
The thesis is under active authoring in LaTeX across chapters covering DevOps theory and the full
SDLC implementation.
