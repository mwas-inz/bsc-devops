# Choose Java and JVM Ecosystem for Backend Development

* Status: accepted
* Date: 2026-04-12
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The bsc-devops project requires a robust and maintainable backend technology stack to implement its core services. The chosen technology must support modern software architecture principles (Clean Architecture, SOLID), have a mature ecosystem of libraries and frameworks, and align with cloud-native requirements such as containerization and observability. Furthermore, the selection should leverage the author's existing proficiency in Java to ensure academic and technical excellence.

## Decision Drivers

* **Developer Expertise:** The author's primary language is Java, which minimizes the learning curve and allows for more advanced implementation.
* **Ecosystem Maturity:** Access to a vast array of production-ready libraries, frameworks (e.g., Spring Boot, Micronaut, Quarkus), and build tools (Gradle, Maven).
* **Cloud-Native Compatibility:** Support for modern containerization practices and the ability to produce efficient, scalable services.
* **Performance and Optimization:** Availability of advanced JVM features and the potential for ahead-of-time (AOT) compilation.

## Considered Options

* **Java / JVM Ecosystem:** A mature, high-performance platform with strong enterprise support.
* **Go (Golang):** Known for its simplicity, performance, and excellent support for cloud-native tooling.
* **Node.js (TypeScript):** Popular for its event-driven architecture and shared language across the full stack.
* **Python:** Widely used for its simplicity and extensive libraries, though often slower in high-performance backend scenarios.

## Decision Outcome

Chosen option: **Java / JVM Ecosystem**, because of the author's deep familiarity with the language and its unparalleled ecosystem for building complex, enterprise-grade applications. To address modern cloud-native constraints (such as slow startup times and high memory usage), the project will specifically target frameworks and tools that support **Native Images** (via GraalVM).

### Consequences

* **Good:** Maximizes productivity by utilizing the author's existing skill set.
* **Good:** Strong support for Clean Architecture and SOLID principles through mature dependency injection and testing frameworks.
* **Good:** Native Image support allows for sub-second startup times and significantly reduced memory footprints, making services ideal for Kubernetes and serverless environments.
* **Bad:** The JVM traditionally has a higher "cold start" memory and CPU overhead compared to languages like Go.
* **Bad:** Building native images increases CI/CD pipeline complexity and build times.

## Pros and Cons of the Options

### Java / JVM Ecosystem (with Native Images)

* Good, because it combines the power of a mature language with modern cloud-native efficiency (AOT).
* Good, because it has excellent IDE support and static analysis tools.
* Bad, because native image compilation can be restrictive (e.g., limited reflection support).
* Bad, because traditional JVM deployments can be resource-intensive.

### Go (Golang)

* Good, because it produces small, fast-starting binaries by default.
* Bad, because it would require the author to learn a new language and ecosystem, potentially impacting the thesis timeline.

### Node.js (TypeScript)

* Good, because of its large community and rapid development cycle.
* Bad, because it lacks the strong multi-threading and enterprise-grade architectural patterns common in the JVM.

### Python

* Good, because it is easy to write and has great libraries for data processing.
* Bad, because its performance in concurrent backend services is generally lower than Java or Go.

## More Information

* GraalVM Native Image: [https://www.graalvm.org/native-image/](https://www.graalvm.org/native-image/)
* Spring Native / Spring Boot 3 AOT: [https://docs.spring.io/spring-boot/docs/current/reference/html/native-image.html](https://docs.spring.io/spring-boot/docs/current/reference/html/native-image.html)
* Quarkus (Kubernetes Native Java): [https://quarkus.io/](https://quarkus.io/)
