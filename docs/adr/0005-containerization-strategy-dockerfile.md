# Containerization Strategy: Dockerfile as the Standard Build Method

* Status: accepted
* Date: 2026-04-26
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The project requires a repeatable method for packaging the Java application as a container image.
Three mainstream approaches exist for Java projects, each with different trade-offs in terms of control, tooling requirements, and transparency.
The choice directly affects the CI/CD pipeline design, image structure, and the educational value of the thesis.

## Decision Drivers

* **Transparency:** The thesis demonstrates the containerization process step by step; the chosen method must make the process visible and explainable.
* **Industry adoption:** The method should reflect real-world practice used by the majority of Java projects.
* **Tooling independence:** The build process should not require vendor-specific plugins tied to a particular build tool.
* **CI/CD compatibility:** Must integrate cleanly with GitHub Actions without additional daemon configuration.
* **Control over best practices:** The method should allow explicit demonstration of good practices (multi-stage builds, non-root user, layer ordering).

## Considered Options

* **Dockerfile** — a declarative text file processed by the Docker build engine.
* **Jib** (Google) — a Maven/Gradle plugin that builds OCI-compliant images without a Docker daemon.
* **Paketo Buildpacks** (CNCF) — a Cloud Native Buildpacks implementation that produces images without a Dockerfile.

## Decision Outcome

Chosen option: **Dockerfile**, because it provides full transparency of the build process, is the de facto industry standard, and allows explicit demonstration of containerization best practices that are directly transferable to any project regardless of language or build tool.

### Consequences

* Good, because the build process is fully explicit and readable, which supports the educational goal of the thesis.
* Good, because Dockerfile is universally understood and requires no additional plugin dependencies in the build system.
* Good, because multi-stage builds, layer ordering optimization, and non-root user configuration can be demonstrated directly in the file.
* Good, because GitHub Actions runners have Docker available natively — no extra setup needed.
* Bad, because the developer must manually maintain the Dockerfile and update the base image for security patches (Paketo Buildpacks handle this automatically).
* Bad, because Java-specific layer optimization (separating dependencies from application code) requires manual configuration, whereas Jib handles this automatically.

## Pros and Cons of the Options

### Dockerfile

* Good, because it is the universal standard recognized across all container runtimes and CI/CD systems.
* Good, because it makes every build step explicit — important for a thesis demonstrating the process.
* Good, because it supports multi-stage builds, allowing a small production image without build-time tools.
* Bad, because it requires a Docker daemon (available on GitHub Actions runners by default, but an additional concern for some environments).
* Bad, because layer caching and optimization must be configured manually (e.g., copying dependencies before source code).

### Jib

* Good, because it eliminates the Docker daemon requirement entirely.
* Good, because it automatically produces optimally layered images (dependencies, resources, classes as separate layers).
* Good, because it integrates directly with Gradle/Maven without a separate build step.
* Bad, because it is Java/JVM-specific and cannot be used for other runtimes (e.g., a Node.js frontend).
* Bad, because the image construction is opaque — the developer does not see or control individual layers directly.
* Bad, because it adds a vendor-specific plugin dependency to the build configuration.

### Paketo Buildpacks

* Good, because it requires zero Dockerfile and follows the CNCF Cloud Native Buildpacks standard.
* Good, because base images are automatically kept up to date (rebasing without full rebuild).
* Good, because it supports multiple runtimes with a unified interface.
* Bad, because the build process is a black box — difficult to explain step by step in an academic context.
* Bad, because local setup requires the `pack` CLI or specific Buildpacks runner, adding tooling overhead.
* Bad, because customizing the build (e.g., native image, custom JVM flags) is less straightforward than editing a Dockerfile.

## More Information

* [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
* [Jib project](https://github.com/GoogleContainerTools/jib)
* [Paketo Buildpacks](https://paketo.io/)
* [Cloud Native Buildpacks specification](https://buildpacks.io/)
* Related: ADR-0003 (Java/JVM backend technology)
