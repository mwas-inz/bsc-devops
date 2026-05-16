# GitHub as VCS and CI/CD Platform

* Status: accepted
* Date: 2026-05-17
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The project requires a version control system and a CI/CD platform. The platform must support
monorepo workflows, integrate with container registries, and allow pipeline-as-code (YAML-based
workflow definitions). It must also be free for public/student repositories.

## Decision Drivers

* Pipeline-as-code: workflows defined in YAML, versioned alongside source code.
* Native integration with Docker Hub, cosign, and Trivy GitHub Actions.
* Free tier suitable for open-source / academic projects.
* Market dominance — the de facto standard for open-source and most enterprise projects.
* Integration with Jira for issue tracking.

## Considered Options

* **GitHub** — cloud-hosted Git platform with built-in GitHub Actions CI/CD.
* **GitLab** — self-hostable Git platform with built-in GitLab CI/CD.
* **Bitbucket** — Atlassian's Git platform, native Jira integration, Bitbucket Pipelines.
* **Gitea** — lightweight self-hosted Git platform, requires separate CI (e.g., Woodpecker CI).

## Decision Outcome

Chosen option: "GitHub", because it is the industry-standard platform with the richest ecosystem
of pre-built Actions, native Cosign and Trivy integrations, and zero infrastructure overhead
for an academic project. Its free tier is sufficient for all CI/CD needs of this project.

### Consequences

* Good, because GitHub Actions marketplace provides ready-made steps for Trivy, Cosign, Docker.
* Good, because the repository is publicly accessible, supporting open science principles.
* Good, because Jira ↔ GitHub integration enables end-to-end traceability from ticket to commit.
* Bad, because it introduces a dependency on a proprietary cloud platform (vendor lock-in).
* Bad, because free-tier runner minutes are limited (2000 min/month for private repos).

## Pros and Cons of the Options

### GitHub

* Good, because of the largest ecosystem of pre-built Actions.
* Good, because of zero setup cost for cloud runners.
* Bad, because of vendor lock-in risk compared to self-hosted alternatives.

### GitLab

* Good, because of self-hosting option (full data sovereignty).
* Good, because of built-in container registry and security scanning.
* Bad, because of higher operational overhead for self-hosted deployments.

### Bitbucket

* Good, because of native Jira integration (same Atlassian suite).
* Bad, because of smaller Actions ecosystem compared to GitHub.

### Gitea

* Good, because of minimal, self-hosted option.
* Bad, because of requiring a separate CI system (higher total complexity).

## More Information

* [GitHub Actions Documentation](https://docs.github.com/en/actions)
* Related: ADR-0004 (Conventional Commits — automated changelog via GitHub Actions)
