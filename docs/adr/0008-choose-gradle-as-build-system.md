# Choose Gradle as Build System for Monorepository

* Status: accepted
* Date: 2026-05-03
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The bsc-devops project is a monorepository containing multiple components (Java backend, frontend, infrastructure). We need a robust build system that supports multi-project builds, dependency management, and efficient build processes (caching, parallel execution) to support the DevOps lifecycle described in the thesis.

## Decision Drivers

* Support for multi-project (monorepo) structure.
* Build performance (incremental builds, build cache).
* Flexibility and extensibility (Groovy/Kotlin DSL).
* Strong integration with the Java/Quarkus ecosystem.
* Industry standard for Java projects.

## Considered Options

* **Gradle**: Flexible, performance-oriented build tool using Groovy or Kotlin DSL.
* **Maven**: Conventional, XML-based build tool.
* **Bazel**: High-performance, multi-language build system often used for very large monorepos.

## Decision Outcome

Chosen option: "Gradle", because it offers the best balance between flexibility and ease of use for a Java-centric monorepo. Its incremental build capabilities and build cache are essential for efficient CI/CD pipelines. It also has excellent support for Quarkus.

### Consequences

* Good, because it simplifies managing dependencies between `libs/` and `apps/`.
* Good, because it allows for fast builds in GitHub Actions.
* Good, because it is the chosen tool described in the thesis (Chapter 3).
* Bad, because it has a steeper learning curve compared to Maven.
* Bad, because Gradle wrapper and configuration files add some boilerplate to the root directory.

## Pros and Cons of the Options

### Gradle

* Good, because of high performance (build cache, daemon).
* Good, because of flexible DSL (Kotlin).
* Good, because of native support for multi-project builds.
* Bad, because configuration can become complex.

### Maven

* Good, because of simplicity and "convention over configuration".
* Good, because it's very stable and well-known.
* Bad, because multi-module builds are less flexible than Gradle.
* Bad, because build performance is generally slower for large projects.

### Bazel

* Good, because of extreme performance and hermetic builds.
* Bad, because of very high complexity and overhead for a small/medium project.

## More Information

* [Gradle Documentation](https://docs.gradle.org/current/userguide/userguide.html)
* [Quarkus Gradle Guide](https://quarkus.io/guides/gradle-tooling)
