# Use ADR with MADR format as Architectural Decision Record template

* Status: accepted
* Date: 2026-04-06
* Decision-makers: mateusz.was
* Consulted: -
* Informed: -

## Context and Problem Statement

To maintain a consistent and structured approach to architectural decisions in this engineering thesis, we need a standardized template. The repository follows an "ADR First" principle, which requires a clear format for documenting choices.

## Decision Drivers

* Consistency across all architectural decisions.
* Clarity for academic evaluation (Engineering Thesis).
* Ease of use within a Markdown-based monorepo.
* Industry and community standards.

## Considered Options

* MADR (Markdown Architectural Decision Records)
* Nygard ADR template
* Custom informal Markdown files

## Decision Outcome

Chosen option: "MADR", because it provides a lean, comprehensive, and widely recognized structure that fits well with the academic and technical requirements of the project. We will use the `adr-template-bare.md` version for maximum flexibility.

### Consequences

* Good, because decisions will be well-documented and easy to follow.
* Good, because it aligns with the "ADR First" principle of the project.
* Bad, because it adds a small overhead to the decision-making process.

## Pros and Cons of the Options

### MADR

* Good, because it is structured and covers context, drivers, and consequences.
* Good, because it is easy to read in a browser and IDE.
* Bad, because it is more verbose than a simple list.

### Nygard ADR template

* Good, because it is the original ADR format.
* Bad, because it is slightly less detailed regarding "Pros and Cons" of alternatives compared to MADR.

## More Information

Project home: [https://github.com/adr/madr](https://github.com/adr/madr)
Template used: `template/adr-template-bare.md`
