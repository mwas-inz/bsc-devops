# Use Conventional Commits for version control history

* Status: accepted
* Date: 2026-04-21
* Decision-makers: Mateusz Waś

## Context and Problem Statement

As the project grows and incorporates more automation (CI/CD), there is a need for a standardized way of documenting changes in the version control system. Without a standard, commit messages are inconsistent, making it difficult to understand the history, generate automated changelogs, and manage semantic versioning.

## Decision Drivers

* Standardization of commit messages across the monorepo.
* Automation of changelog generation and semantic versioning.
* Improved clarity for contributors and reviewers.
* Compatibility with standard DevOps tooling.

## Considered Options

* **Conventional Commits:** A lightweight convention on top of commit messages.
* **Freeform commits:** No specific standard enforced.
* **Gitmoji:** Using emojis to categorize commits.

## Decision Outcome

Chosen option: "Conventional Commits", because it provides a structured and machine-readable way to categorize changes while remaining simple for developers to follow. It is the industry standard for automated versioning and changelog generation.

### Consequences

* Good, because it enables automated tools to determine version bumps (semver).
* Good, because it makes the `git log` much more readable and searchable.
* Good, because it integrates well with CI/CD pipelines for automated releases.
* Bad, because it requires a learning curve for contributors and potentially linting tools to enforce the standard.

## Pros and Cons of the Options

### Conventional Commits

* Good, because it is widely adopted and has excellent tooling support (e.g., commitlint, semantic-release).
* Good, because it clearly distinguishes between features, fixes, and breaking changes.
* Bad, because it requires discipline from developers to format messages correctly.

### Freeform commits

* Good, because it has zero overhead for the developer.
* Bad, because it is impossible to automate changelogs or versioning reliably.
* Bad, because history quality depends entirely on individual effort.

### Gitmoji

* Good, because it is visually appealing and quick to scan.
* Bad, because it is less "machine-readable" for standard automation tools compared to Conventional Commits.
* Bad, because it can be seen as less professional in some academic or corporate contexts.

## More Information

* [Conventional Commits Specification](https://www.conventionalcommits.org/)
