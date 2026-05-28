# Cosign Keyless Signing for Container Images

* Status: accepted
* Date: 2026-05-28
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

After a container image is built and scanned, the CI pipeline must attest its provenance —
proving that the image was produced by a specific pipeline run and has not been tampered with
since. We need a signing mechanism that integrates with GitHub Actions without requiring
long-lived secret keys stored in the repository.

## Decision Drivers

* No long-lived signing keys to rotate or leak — reduces operational risk.
* Native integration with GitHub Actions OIDC token (identity-based signing).
* Verifiable on the consumer side without trusting a centralised key store.
* Alignment with the CNCF supply-chain security ecosystem (SLSA, Sigstore).
* Open-source and free to operate.

## Considered Options

* **Cosign keyless (Sigstore)** — signs using a short-lived certificate issued against the
  GitHub Actions OIDC identity; signature stored in Rekor transparency log.
* **Cosign with static key pair** — signs with a private key stored as a GitHub Actions secret.
* **Notary v2 / Docker Content Trust** — OCI-native signing standard backed by The Update
  Framework (TUF).

## Decision Outcome

Chosen option: "Cosign keyless (Sigstore)", because it eliminates long-lived key management
entirely — the signing identity is the GitHub Actions OIDC token, and every signature is
recorded in the public Rekor transparency log, enabling third-party verification without
distributing a public key.

### Consequences

* Good, because no private key needs to be stored as a repository secret.
* Good, because signatures are publicly auditable via the Rekor transparency log.
* Good, because `sigstore/cosign-installer` GitHub Action provides zero-configuration setup.
* Good, because aligns with SLSA Level 2+ supply-chain provenance requirements.
* Bad, because keyless verification requires network access to Rekor/Fulcio at verify time.
* Bad, because the OIDC-based certificate is tied to the GitHub Actions run identity, so
  offline or air-gapped verification requires an alternative trust root.

## Pros and Cons of the Options

### Cosign keyless (Sigstore)

* Good, because no secret key management burden.
* Good, because transparency log provides tamper-evident audit trail.
* Good, because first-class GitHub Actions integration (`sigstore/cosign-installer`).
* Bad, because depends on Sigstore public infrastructure (Rekor, Fulcio) being available.

### Cosign with static key pair

* Good, because verification works fully offline with the public key.
* Good, because same `cosign` toolchain — low switching cost.
* Bad, because private key must be stored as a GitHub Actions secret and rotated periodically.
* Bad, because leaked key invalidates all previously signed images retroactively.

### Notary v2 / Docker Content Trust

* Good, because OCI-native standard with broad registry support.
* Bad, because more complex TUF key hierarchy to operate.
* Bad, because GitHub Actions integration is less mature than Cosign.

## More Information

* [Sigstore / Cosign](https://github.com/sigstore/cosign)
* [sigstore/cosign-installer GitHub Action](https://github.com/sigstore/cosign-installer)
* [Rekor transparency log](https://rekor.sigstore.dev)
* Related: ADR-0010 (Trivy — scanning the image before signing), ADR-0009 (GitHub Actions CI)
