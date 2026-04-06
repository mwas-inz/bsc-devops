# bsc-devops

Monorepository for an engineering thesis focused on modern DevOps and cloud-native SDLC practices.

This repository combines Java application development, infrastructure as code, technical documentation, and thesis assets in one structure.

## Core Principles

- **ADR First**: Major architectural changes must be documented in `docs/adr/`.
- **Java Excellence**: Apply Clean Architecture and SOLID; keep business logic in `libs/` framework-agnostic where possible.
- **Cloud Native & DevOps**: Design for observability, scalability, and portability; follow 12-factor application practices.
- **Academic Rigor**: Keep thesis language formal and align implementation details with thesis descriptions.

## Repository Structure

- `apps/` - executable services (for example Spring Boot applications)
- `libs/` - shared domain logic and utility modules
- `infrastructure/` - infrastructure as code (Docker, Kubernetes, Terraform/Pulumi)
- `docs/` - ADRs, diagrams, and technical documentation
- `docs/adr/` - architecture decision records
- `docs/diagrams/` - shared architecture and flow diagrams
- `cicd/` - CI/CD planning and workflow notes
- `gitops/` - GitOps planning and delivery notes
- `observability/` - monitoring, logging, and tracing notes
- `thesis/` - thesis text and academic assets
- `scripts/` - shared helper scripts and developer workflow notes

## Status

This is a work in progress.
The structure is being defined and initial content is being drafted. The focus is on creating a clear, maintainable organization for both the technical implementation and the thesis documentation.
