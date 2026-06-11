# Sealed Secrets for Kubernetes Secrets Management

* Status: accepted
* Date: 2026-06-11
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The delivery model is pull-based GitOps (ADR-0013): ArgoCD reconciles the cluster to
match a Git repository, and the Helm chart (ADR-0012) is the single source of truth for
what runs in the `bsc-devops` namespace. This creates a conflict for sensitive values —
the PostgreSQL password and the datasource password. A native Kubernetes `Secret` only
base64-encodes its data, and committing chart values or rendered Secrets to Git would
publish those credentials in plaintext to every clone and to the OCI registry hosting the
chart. The project needs a way to keep secret material **encrypted at rest in Git** while
still letting ArgoCD apply it declaratively, with no manual `kubectl` step outside the
GitOps loop.

## Decision Drivers

* Credentials must never appear in plaintext in Git, in `values.yaml`, or in the
  published chart.
* The encrypted artifact must be safe to commit and reconcilable by ArgoCD like any other
  manifest (declarative, pull-based).
* Must run in a single-node k3d cluster (ADR-0015) without external cloud dependencies.
* Must be operable by a single developer and simple enough to demonstrate and document in
  the thesis.
* Decryption keys must stay inside the cluster and never leave it.

## Considered Options

* **Bitnami Sealed Secrets** — an in-cluster controller plus the `kubeseal` CLI; encrypts a
  Secret into a `SealedSecret` CRD that only the controller can decrypt.
* **External Secrets Operator (ESO)** — syncs Secrets from an external store (Vault, cloud
  secret managers) into the cluster.
* **HashiCorp Vault** — a dedicated secrets-management server with dynamic secrets and
  fine-grained policies.
* **SOPS (+ age/GPG)** — file-level encryption of YAML, decrypted at apply time (e.g. via a
  Flux/Argo plugin or pre-apply step).

## Decision Outcome

Chosen option: "Bitnami Sealed Secrets", because it is the only option that keeps secrets
encrypted in Git **and** is reconcilable by ArgoCD with no external system and no
out-of-band step. A `SealedSecret` is a plain CRD that lives next to the chart in
`gitops/secrets/`; the controller decrypts it into a normal `Secret` in the target
namespace. The asymmetric key never leaves the cluster, so the same encrypted file is safe
in a public repository.

### Consequences

* Good, because the encrypted `SealedSecret` manifests are committed to Git, preserving a
  fully declarative GitOps history without leaking credentials.
* Good, because no external secret store or network dependency is required — the controller
  runs in-cluster, fitting the constrained local k3d environment.
* Good, because sealing is namespace- and name-scoped by default, so a sealed value cannot
  be re-used under a different name or namespace.
* Good, because the Helm chart no longer renders Secrets at all — `values.yaml` carries no
  password, removing the largest plaintext-leak surface.
* Bad, because the controller's private key is a single point of trust: losing it (without
  a backup) makes every existing `SealedSecret` undecryptable and forces a re-seal.
* Bad, because rotating a secret requires re-running `kubeseal` and committing a new
  manifest — there is no dynamic/short-lived secret capability as in Vault.
* Bad, because the decrypted `Secret` still exists in etcd in base64 form, so this protects
  secrets *in Git*, not *at rest in the cluster* (which would need encryption-at-rest/KMS).

## Pros and Cons of the Options

### Bitnami Sealed Secrets

* Good, because it is purpose-built for the "encrypt secrets for Git" problem and needs
  only one lightweight controller plus a CLI.
* Good, because `SealedSecret` is a standard CRD that ArgoCD reconciles like any manifest.
* Good, because the private key stays in the cluster; the public cert is all that is needed
  to seal.
* Bad, because key custody/backup becomes an operational responsibility.
* Bad, because secret rotation is a manual re-seal rather than automatic.

### External Secrets Operator

* Good, because it centralises secrets in a dedicated store and supports rotation.
* Bad, because it requires an external backend (Vault or a cloud secret manager), which
  contradicts the self-contained local k3d constraint and adds cost/setup.

### HashiCorp Vault

* Good, because it offers dynamic secrets, leasing, and fine-grained policies — the most
  powerful option.
* Bad, because running and unsealing a Vault server is heavy operational overhead for a
  single-developer thesis project on one k3d node.

### SOPS (+ age/GPG)

* Good, because it encrypts arbitrary YAML at the file level and is simple to start with.
* Bad, because native ArgoCD has no built-in SOPS decryption — it needs a custom plugin or
  a pre-apply step, breaking the clean pull-based reconciliation that ADR-0013 establishes.

## More Information

* Sealed manifests: `gitops/secrets/db-secret.sealed.yaml`,
  `gitops/secrets/postgres-secret.sealed.yaml`, `gitops/secrets/dockerhub-pull-secret.sealed.yaml`.
* Controller: Bitnami `sealed-secrets` in `kube-system`; sealing via `kubeseal`.
* Tool card: `docs/tech-card/sealed-secrets.md`.
* Related: ADR-0002 (Kubernetes runtime), ADR-0012 (Helm packaging), ADR-0013 (ArgoCD GitOps),
  ADR-0015 (k3d local runtime). Implements the secrets requirement of INZ-19.
