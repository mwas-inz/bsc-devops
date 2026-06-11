# GitOps

GitOps delivery using ArgoCD and Sealed Secrets.

## How It Works

ArgoCD reconciles the `bsc-devops` Helm chart from GHCR into the local k3d cluster.
Registry credentials and the PostgreSQL password are stored as Sealed Secrets in Git —
no plaintext tokens are committed.

## Files

| File | Purpose |
| --- | --- |
| `application.yaml` | ArgoCD Application manifest pointing to the GHCR OCI chart |
| `secrets/ghcr-docker-config.sealed.yaml` | GHCR pull credentials for ArgoCD to fetch the OCI chart |
| `secrets/db-secret.sealed.yaml` | Database connection URL secret for application services |
| `secrets/postgres-secret.sealed.yaml` | PostgreSQL superuser credentials |
| `secrets/dockerhub-pull-secret.sealed.yaml` | DockerHub pull secret (rate-limit mitigation) |
| `argocd/install.sh` / `install.ps1` | Installs ArgoCD via Helm into the `argocd` namespace |

## Bootstrap

See `scripts/README.md` for the full GitOps bootstrap walkthrough.
The one-command entry point is `bash scripts/local/gitops-bootstrap.sh`.
