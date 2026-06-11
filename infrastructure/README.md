# Infrastructure

Infrastructure as code for the bsc-devops thesis platform.

## Helm Chart

`helm/bsc-devops/` is an umbrella Helm chart (v0.6.0) that packages all application services.
It is published to GHCR as an OCI chart via the `cd-helm` GitHub Actions workflow whenever a
`chart-*` git tag is pushed.

The chart renders Kubernetes resources for the following components:

| Component | Template |
| --- | --- |
| Namespace and RBAC | `namespace.yaml`, `rbac.yaml` |
| `users` service | `users.yaml` |
| `tasks` service | `tasks.yaml` |
| `task-archiver` service | `task-archiver.yaml` |
| Vue 3 frontend | `frontend.yaml` |
| PostgreSQL | `postgres.yaml` |
| Apache Pulsar | `pulsar.yaml` |
| Jaeger (tracing) | `jaeger.yaml` |
| API Ingress | `api-ingress.yaml` |
| Shared ConfigMap | `configmap.yaml` |

## Local Manifests

`local/` contains raw Kubernetes manifests that mirror the Helm chart for debugging outside the
GitOps flow. These are applied by `scripts/local/deploy-k3d.sh`.

## docker-compose.yml

`docker-compose.yml` starts all services locally without Kubernetes.
Useful for fast feedback during development without standing up a cluster.
