# Adopt ADRs as Design Driver and MADR as the Standard Format

* Status: accepted
* Date: 2026-04-06
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

For an engineering thesis focused on DevOps and SDLC, it is crucial to document not just the final state of the infrastructure and code, but the reasoning behind technical choices. We need a mechanism to enforce "Architecture First" thinking and provide a clear audit trail for academic evaluation.

## Decision Drivers

* **Academic Rigor:** Documentation of the decision-making process is as important as the implementation itself.
* **Traceability:** Need to link requirements and constraints to specific technical outcomes.
* **Consistency:** All contributors (and AI assistants) must follow a unified format.
* **Knowledge Retention:** Avoid losing "why" decisions were made during the long-term development of the thesis.

## Considered Options

* **ADR (Architecture Decision Records):** Formal documents capturing a single decision and its context.
* **Commit Messages Only:** Relying on git history to explain choices.
* **Wiki/Informal Docs:** Maintaining a separate document with a list of choices.

## Decision Outcome

Chosen option: **ADR (Architecture Decision Records)** using the **MADR (Markdown Architectural Decision Records)** format.

ADRs will serve as the primary design driver for the project. By forcing a "Decision First" workflow, we ensure that every major component (CI/CD tools, Java libraries, Cloud providers) is justified.

MADR was chosen as the specific template because it provides a lean, comprehensive structure (context, drivers, pros/cons of alternatives) that is perfectly suited for academic documentation.

### Consequences

* **Good:** Every major architectural change will have a dedicated, versioned record.
* **Good:** The thesis can directly reference these records to justify the chosen solution.
* **Good:** Standardized template (MADR) makes it easy for AI to assist in generating or reviewing decisions.
* **Bad:** Slight overhead in the development process as documentation must precede or accompany implementation.

## Pros and Cons of the Options

### ADR with MADR Format

* Good, because it is structured and covers context, drivers, and consequences.
* Good, because it is a widely recognized industry standard.
* Good, because it integrates with the Git-based monorepo workflow.
* Bad, because it requires discipline to maintain.

### Commit Messages Only

* Good, because it's zero overhead.
* Bad, because commit messages are often too brief and difficult to reference in an academic paper.

### Wiki/Informal Docs

* Good, because it's flexible.
* Bad, because it lacks a standardized structure, leading to inconsistent levels of detail.

## More Information

* MADR Project: [https://github.com/adr/madr](https://github.com/adr/madr)
* ADR Concept: [Documenting Architecture Decisions (Michael Nygard)](https://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)
