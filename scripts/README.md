# Scripts

This folder contains helper scripts and workflow automation for the project.

## Subdirectories

- [thesis/](./thesis/README.md): Scripts and documentation for compiling and managing the LaTeX thesis.
- [local/](./local/): Scripts for running and managing the local k3d development environment.

## local/ — Local environment scripts

### GitOps workflow (recommended)

The GitOps workflow uses ArgoCD to deploy the application from the GHCR Helm chart.
Credentials are stored as Sealed Secrets in Git — no tokens are needed at bootstrap time.

**One-time setup (or after credential rotation):**

```sh
# Requires: GHCR_TOKEN and ARGO_DOCKERHUB_TOKEN environment variables
bash scripts/local/seal-secrets.sh
# Commit the output: gitops/secrets/*.sealed.yaml
```

**Bootstrap a fresh cluster (no tokens required):**

```sh
bash scripts/local/gitops-bootstrap.sh
```

This runs five steps in order:

| Step | Action                                                                              |
| ---- | ----------------------------------------------------------------------------------- |
| 1    | Create k3d cluster (`bsc-devops`) with Ingress port mapping                         |
| 2    | Install Sealed Secrets controller (Helm, `kube-system`)                             |
| 3    | Apply `gitops/secrets/*.sealed.yaml` — controller decrypts into Kubernetes Secrets  |
| 4    | Install ArgoCD (Helm, `argocd`) — mounts GHCR Docker config for OCI chart pull      |
| 5    | Apply `gitops/application.yaml` — ArgoCD syncs `bsc-devops` chart from GHCR         |

After bootstrap, ArgoCD manages all subsequent deployments automatically.
Pushing a new chart version to GHCR and updating `targetRevision` in
`gitops/application.yaml` is all that is needed to trigger a rollout.

**Day-2 updates (after a chart change is published):**

| Script                      | Description                                                                                            |
| --------------------------- | ------------------------------------------------------------------------------------------------------ |
| `argocd-update.sh` / `.ps1` | Bump apps `targetRevision`, commit, push, and re-apply the apps Application.                           |
| `observability-update.sh`   | Re-apply + hard-refresh the observability Application; optional version bump; probes the UI hostnames. |
| `observability-rollout.sh`  | One-time Etap Monitor rollout: apps sync, Grafana admin secret, LGTM + Collector delivery.             |

### Legacy scripts

These scripts deploy the application directly without ArgoCD, useful for quick
iteration or debugging outside the GitOps flow.

| Script                     | Description                                                                                      |
| -------------------------- | ------------------------------------------------------------------------------------------------ |
| `deploy-k3d.sh` / `.ps1`   | Deploy using raw `kubectl apply` manifests. Accepts an optional `IMAGE_TAG` (defaults to SHA).   |
| `helm-deploy.sh` / `.ps1`  | Deploy using `helm upgrade --install` against the local chart. Accepts an optional `IMAGE_TAG`.  |

### Sealed Secrets — key management note

Sealed Secret ciphertexts are bound to the Sealed Secrets controller key pair
in the cluster. If the cluster is deleted and recreated, the controller generates
a new key pair and the existing sealed files can no longer be decrypted.

**Before deleting the cluster**, back up the key pair:

```sh
kubectl get secret -n kube-system \
  -l sealedsecrets.bitnami.com/sealed-secrets-key \
  -o yaml > gitops/secrets/sealed-secrets-key.backup.yaml
# Do NOT commit this file to Git.
```

To restore: `kubectl apply -f gitops/secrets/sealed-secrets-key.backup.yaml`
before installing the Sealed Secrets controller, then proceed with the bootstrap.
Alternatively, re-run `seal-secrets.sh` to re-seal with the new cluster key.
