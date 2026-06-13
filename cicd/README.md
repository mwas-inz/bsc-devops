# CI/CD

CI/CD is implemented with GitHub Actions in `.github/workflows/`.

## Workflows

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `ci-users` | push/PR on `apps/users/**` | Build, test, Trivy scan, push image to GHCR, Cosign sign |
| `ci-tasks` | push/PR on `apps/tasks/**` | Build, test, Trivy scan, push image to GHCR, Cosign sign |
| `ci-task-archiver` | push/PR on `apps/task-archiver/**` | Build, test, Trivy scan, push image to GHCR, Cosign sign |
| `ci-frontend` | push/PR on `apps/frontend/**` | Install, lint, test (Vitest), Docker build, push to GHCR |
| `ci-helm` | push/PR on `infrastructure/helm/**` | `helm lint`, render, `kubeconform` validate, auto-tag `chart-apps-*` / `chart-observability-*` |
| `cd-helm` | push of `chart-apps-*` / `chart-observability-*` tag | Package and push OCI charts to GHCR |
| `release` | push of `*-v*` tag | Retag and Cosign-sign the final release image |
| `release-please` | push to `main` | Automates changelogs and release PRs |
| `thesis` | push/PR on `thesis/**` | Compile LaTeX thesis to PDF |

## Image Registry

All container images and the Helm chart are published to GitHub Container Registry (GHCR)
under `ghcr.io/mwas-inz/`.
