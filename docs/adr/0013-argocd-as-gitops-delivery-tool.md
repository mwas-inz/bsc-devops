# ArgoCD as GitOps Delivery Tool

* Status: accepted
* Date: 2026-06-09
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

With Helm adopted as the Kubernetes packaging standard (ADR-0012), the project needs
a GitOps controller to own the delivery loop: watch a Git repository for changes and
reconcile the cluster state to match. Two CNCF-graduated tools dominate this space —
ArgoCD and Flux. Both follow the pull-based GitOps model, support Helm chart sources
natively, and integrate with GitHub. A choice must be made so that the CI/CD pipeline
(GitHub Actions → GHCR → cluster) can be closed end-to-end and documented in the thesis.

## Decision Drivers

* Must support Helm chart sources stored in an OCI registry (GHCR).
* Must be deployable in a single-node k3d cluster within the resource constraints of
  a local development machine (ADR-0015).
* Should provide observable feedback on sync status — important for thesis screenshots
  and live demonstrations.
* Must be learnable and operable by a single developer without a dedicated ops team.
* Should be the de-facto standard cited in current industry and academic literature to
  support the thesis argument.

## Considered Options

* **ArgoCD** — Kubernetes controller with a built-in web UI and CLI; CNCF graduated.
* **Flux** — GitOps Toolkit of composable Kubernetes controllers; CNCF graduated; no built-in UI.

## Decision Outcome

Chosen option: "ArgoCD", because it provides first-class Helm OCI support, an
observable web UI that makes sync state immediately visible for thesis demonstrations,
and is the most widely cited GitOps tool in the CNCF landscape survey — making it the
stronger reference for the academic context of this project.

### Consequences

* Good, because the ArgoCD UI gives a real-time, visual representation of the application
  sync tree — directly usable as a thesis figure.
* Good, because `argocd app sync` and the UI both surface Helm diff output, making
  release changes auditable without extra tooling.
* Good, because ArgoCD Application CRDs are stored in Git alongside the Helm chart,
  keeping the full delivery definition version-controlled.
* Good, because the ArgoCD Helm source supports OCI registries directly, matching the
  GHCR chart distribution set up in ADR-0012.
* Bad, because the ArgoCD server, repo-server, application-controller, and Redis pods
  consume more memory (~300 MB) than the Flux controller set (~80 MB) — relevant on a
  resource-constrained k3d node.
* Bad, because the web UI is an additional attack surface not present in the Flux
  model, requiring network policy or ingress auth in a production hardening scenario.

## Pros and Cons of the Options

### ArgoCD

* Good, because the built-in web UI visualises the full application resource tree and
  sync status without any additional tooling.
* Good, because Application and AppProject CRDs are a well-understood abstraction for
  declaring what should run in which cluster/namespace.
* Good, because OCI Helm source support is stable since ArgoCD 2.6.
* Good, because it is the most-referenced GitOps tool in the 2024 CNCF Annual Survey.
* Bad, because the full installation has a larger pod footprint than Flux (~5 pods vs ~4).
* Bad, because multi-tenancy (AppProject isolation) adds configuration overhead for a
  single-tenant project that does not benefit from it.

### Flux

* Good, because the GitOps Toolkit controllers are small and composable — each
  responsibility (source, kustomize, helm, notification) is a separate controller.
* Good, because the Flux resource model (GitRepository, HelmRelease, HelmRepository) is
  entirely declarative and stored in Git without a separate UI service.
* Good, because lower memory footprint makes it better suited to very constrained local
  environments.
* Bad, because there is no built-in UI — sync status is only visible via `kubectl` or
  third-party dashboards (Weave GitOps), adding setup cost for demonstrations.
* Bad, because debugging a failed HelmRelease requires chaining `kubectl describe`
  across multiple controller logs, which has a steeper learning curve.

## More Information

* Install target: `infrastructure/local/argocd/` (Helm values for ArgoCD chart).
* ArgoCD Application manifest for this project: `gitops/application.yaml`.
* Related: ADR-0002 (Kubernetes runtime), ADR-0012 (Helm packaging), ADR-0015 (k3d local runtime).
