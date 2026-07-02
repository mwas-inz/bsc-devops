# GitOps

GitOps delivery using ArgoCD and Sealed Secrets.

## How It Works

ArgoCD reconciles two Helm charts from GHCR into the local k3d cluster: `bsc-devops-apps`
(application services) and `bsc-devops-observability` (LGTM stack + OTel Collector).
Registry credentials and the PostgreSQL password are stored as Sealed Secrets in Git —
no plaintext tokens are committed.

## Files

| File | Purpose |
| --- | --- |
| `application.yaml` | ArgoCD Application manifest pointing to the GHCR OCI chart |
| `observability.yaml` | ArgoCD Application delivering the observability chart (LGTM + OTel Collector) |
| `secrets/ghcr-docker-config.sealed.yaml` | GHCR pull credentials for ArgoCD to fetch the OCI chart |
| `secrets/grafana-admin.sealed.yaml` | Grafana admin credentials for the observability stack |
| `secrets/db-secret.sealed.yaml` | Database connection URL secret for application services |
| `secrets/postgres-secret.sealed.yaml` | PostgreSQL superuser credentials |
| `secrets/dockerhub-pull-secret.sealed.yaml` | DockerHub pull secret (rate-limit mitigation) |
| `argocd/install.sh` / `install.ps1` | Installs ArgoCD via Helm into the `argocd` namespace |

## ArgoCD UI

The ArgoCD server is exposed through a Traefik ingress at `http://argocd.localhost`
(k3d maps `localhost:80` to Traefik; browsers resolve `*.localhost` to loopback).
The ingress is configured in `infrastructure/local/argocd/values.yaml`
(`server.ingress` with `server.insecure: true` — TLS terminates at Traefik).
It belongs to the ArgoCD Helm release itself, not to an Application, so changes to
those values require a `helm upgrade` (re-running `argocd/install.sh` does this).

Login as `admin` with the initial password:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

## Bootstrap

See `scripts/README.md` for the full GitOps bootstrap walkthrough.
The one-command entry point is `bash scripts/local/gitops-bootstrap.sh`.
