# Trivy as Container Image Vulnerability Scanner

* Status: accepted
* Date: 2026-05-17
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The CI pipeline must scan each built container image for known CVEs before pushing to the
registry. This is the "Shift Left Security" practice described in the thesis. We need a scanner
that integrates natively with GitHub Actions, covers OS packages and application dependencies,
and can fail the build on configurable severity thresholds.

## Decision Drivers

* Native GitHub Actions integration (no self-hosted runner required).
* Scans both OS-level packages and JVM library dependencies (JAR files).
* Configurable severity threshold to fail the build (HIGH/CRITICAL).
* Active maintenance and wide industry adoption.
* Open-source and free to use.

## Considered Options

* **Trivy** — open-source scanner by Aqua Security, covers OS + language packages.
* **Grype** — open-source scanner by Anchore, covers OS + language packages.

## Decision Outcome

Chosen option: "Trivy", because it has a first-class GitHub Action (`aquasecurity/trivy-action`),
broader coverage of package types (including JAR manifests via `--scanners vuln`), and higher
adoption in the Kubernetes/Cloud Native ecosystem. Both tools are functionally comparable;
Trivy's richer Actions ecosystem gives it the edge for this project.

### Consequences

* Good, because `aquasecurity/trivy-action` provides a zero-configuration integration.
* Good, because Trivy is part of the CNCF landscape, consistent with the Cloud Native theme.
* Good, because it produces SARIF output compatible with GitHub Security tab.
* Bad, because Trivy's database updates require internet access in CI runners.
* Bad, because false positives in JVM scanning occasionally require manual suppression.

## Pros and Cons of the Options

### Trivy

* Good, because of official GitHub Action with direct image scanning support.
* Good, because of CNCF project status — well-maintained and widely adopted.
* Good, because of SARIF output for GitHub Security tab integration.
* Bad, because of occasional false positives requiring `.trivyignore` maintenance.

### Grype

* Good, because of clean CLI and JSON output format.
* Good, because of strong Anchore ecosystem integration (Syft for SBOMs).
* Bad, because of no official first-party GitHub Action (community actions only).
* Bad, because of lower adoption in Kubernetes-native toolchains.

## More Information

* [Trivy GitHub Action](https://github.com/aquasecurity/trivy-action)
* [Grype by Anchore](https://github.com/anchore/grype)
* Related: ADR-0005 (Dockerfile — the artefact being scanned)
