# Helm as Kubernetes Package Manager

* Status: accepted
* Date: 2026-06-01
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The project's Kubernetes infrastructure is defined as raw YAML manifests in
`infrastructure/local/`. These manifests contain hardcoded values (image tags, namespace,
resource limits) that must vary across environments and pipeline runs. As the number of
services grew to seven deployments, the manifests became difficult to manage: image tags
required `sed` substitution, there was no release history, and rolling back a failed deploy
meant manually reapplying previous manifest versions. A structured approach to Kubernetes
configuration management is needed.

## Decision Drivers

* Image tags must be injected at deploy time (CI produces a new tag per commit).
* Component enablement must be configurable (e.g. disable infra services when using
  an existing cluster).
* Release history and one-command rollback are required for operational safety.
* The solution must be well-supported in the CNCF ecosystem and suitable for a
  GitOps delivery model (ArgoCD/FluxCD).
* Tooling must be learnable without deep specialist knowledge and well-documented
  for the thesis practical chapter.

## Considered Options

* **Raw Kubernetes manifests with `sed` substitution** — baseline, current state.
* **Kustomize** — overlay-based configuration without templating, built into `kubectl`.
* **Helm** — Go-template-based package manager with release lifecycle management.

## Decision Outcome

Chosen option: "Helm", because it is the only option that combines parameterisation,
release versioning, and rollback in a single tool, while remaining the de-facto standard
in the Kubernetes ecosystem and integrating natively with ArgoCD/FluxCD for the GitOps delivery stage.

### Consequences

* Good, because `helm upgrade --install` is idempotent and tracks the release state in
  the cluster — no external state file is needed.
* Good, because `helm rollback` restores the previous release atomically across all
  resources.
* Good, because `values.yaml` provides a single, documented source of configurable
  parameters, replacing scattered `sed` substitutions.
* Good, because Helm chart repositories are the standard distribution mechanism for
  Kubernetes applications, enabling discoverability via ArtifactHub.
* Good, because ArgoCD and FluxCD support Helm charts natively (ADR-0013).
* Bad, because Go template syntax in `templates/` is verbose and error-prone compared to
  plain YAML overlays.
* Bad, because Helm introduces a client-side dependency (`helm` binary) not required by
  Kustomize (which is built into `kubectl`).
* Bad, because Secrets passed via `--set` appear in the Helm release history stored in
  the cluster — requires `helm-secrets` or an external secrets operator in production.

## Pros and Cons of the Options

### Raw Kubernetes manifests with `sed` substitution

* Good, because no additional tooling is required beyond `kubectl`.
* Good, because every resource is a plain, readable YAML file — no template indirection.
* Bad, because image tag injection via `sed` is fragile (pattern collisions, no validation).
* Bad, because there is no release history: rollback means finding and reapplying old files
  manually.
* Bad, because multi-environment configuration requires duplicating entire manifest trees.

### Kustomize

* Good, because it is built into `kubectl apply -k` — no extra binary to install.
* Good, because it uses plain YAML overlays (patches) rather than a templating language,
  so base manifests remain fully readable.
* Good, because the overlay model (base + overlays per environment) is conceptually clean
  and well-suited to GitOps with Flux.
* Bad, because it has no release lifecycle concept — there is no history, versioning, or
  rollback mechanism.
* Bad, because arbitrary value injection (e.g. an image tag from CI) requires either a
  dedicated `kustomize edit set image` call or a variable substitution plugin, adding
  scripting complexity.
* Bad, because packaging and distributing a Kustomize configuration for external consumers
  is less standardised than a Helm chart.

### Helm

* Good, because parameterisation via `values.yaml` and `--set` is first-class and
  well-documented.
* Good, because release versioning and `helm rollback` provide operational safety without
  external tooling.
* Good, because the Helm chart format is the dominant Kubernetes packaging standard,
  with ArtifactHub as the central registry.
* Good, because ArgoCD and FluxCD support Helm chart sources natively.
* Bad, because Go template syntax adds indirection and increases the learning curve compared
  to plain YAML.
* Bad, because the `helm` CLI is an additional dependency not bundled with Kubernetes.

## More Information

* Chart location: `infrastructure/helm/bsc-devops/`
* Deploy script: `scripts/local/helm-deploy.sh` / `scripts/local/helm-deploy.ps1`
* Related: ADR-0002 (Kubernetes as runtime), ADR-0013 (ArgoCD vs FluxCD — GitOps delivery)
