# Adopt OpenTelemetry as the Unified Observability Standard

* Status: accepted
* Date: 2026-04-26
* Decision-makers: Mateusz Waś
* Consulted:
* Informed:

> **Amendment (2026-06-12, INZ-24):** This ADR refers throughout to the OpenTelemetry
> **Java agent** as the auto-instrumentation mechanism. For this project's services
> that delivery choice is **superseded**: the applications instrument via the
> **Quarkus OpenTelemetry extension** (`quarkus-opentelemetry`, build-time
> instrumentation) instead of the `-javaagent`. The Java agent performs bytecode
> instrumentation at JVM startup and is therefore incompatible with the **GraalVM
> native images** the services are built as (ADR-0003), and it would
> double-instrument when combined with the Quarkus extension already in use.
> The decision to standardise on **OpenTelemetry** is unchanged — only the
> agent-vs-extension delivery differs. Likewise, structured JSON logging is provided
> by the `quarkus-logging-json` extension (Quarkus uses JBoss LogManager, not
> Logback), with trace context (`traceId`/`spanId`) injected automatically by the
> OTel extension's MDC integration.

## Context and Problem Statement

Observability is built on three pillars: logs, metrics, and distributed traces.
Without a unified standard, each pillar requires its own instrumentation library, which couples the application to specific vendors and backends.
Changing or adding a backend later requires modifying application code.
A vendor-neutral standard would allow the application to emit telemetry once and route it to any backend.

## Decision Drivers

* **Vendor neutrality:** Instrumentation in application code must not depend on the chosen storage backend.
* **Unified API:** A single SDK covering all three pillars reduces cognitive overhead and dependency sprawl.
* **Auto-instrumentation:** For a Java application, the instrumentation should require minimal code changes.
* **CNCF alignment:** The chosen standard should align with the cloud-native ecosystem already adopted in ADR-0002.
* **Community adoption:** The standard must have broad tooling support so that any backend can consume the telemetry.

## Considered Options

* **OpenTelemetry (CNCF)** — a vendor-neutral, unified standard for logs, metrics, and traces with a Java agent for auto-instrumentation.
* **Vendor-specific libraries** — Micrometer (metrics) + SLF4J/Logback (logs) + Brave/Zipkin (traces) used independently.
* **All-in-one SaaS agent** — Datadog Agent or Dynatrace OneAgent providing auto-instrumentation as a managed service.

## Decision Outcome

Chosen option: **OpenTelemetry**, because it is the CNCF standard for observability, covers all three pillars with a single SDK and Collector, and provides a Java agent that instruments the application automatically without modifying source code.

### Consequences

* Good, because the application is decoupled from any specific observability backend — backends can be swapped by reconfiguring the Collector, not the application.
* Good, because the Java agent enables auto-instrumentation (HTTP, JDBC, gRPC, etc.) with zero code changes.
* Good, because a single OTel Collector acts as the central telemetry pipeline, handling routing, batching, and enrichment.
* Good, because OpenTelemetry is the de facto CNCF standard with first-class support in all major backends (Prometheus, Loki, Tempo, Jaeger, Zipkin, Datadog, etc.).
* Bad, because the OTel specification is still evolving — the logs signal reached stable status later than metrics and traces, and some APIs may change between minor versions.
* Bad, because the Collector adds one more component to operate and configure.

## Pros and Cons of the Options

### OpenTelemetry

* Good, because it is a CNCF project with industry-wide adoption and a clear governance model.
* Good, because the Java agent requires only a JVM flag (`-javaagent`) — no changes to application code.
* Good, because the OTel Collector can fan out to multiple backends simultaneously.
* Bad, because configuration of the Collector (receivers, processors, exporters, pipelines) has a learning curve.

### Vendor-specific libraries (Micrometer + SLF4J + Brave)

* Good, because each library is mature and well-documented for its specific domain.
* Good, because Micrometer is already the standard metrics facade in Spring Boot and Quarkus.
* Bad, because there is no unified pipeline — logs, metrics, and traces are sent via separate paths.
* Bad, because changing the metrics backend (e.g., from Prometheus to Mimir) may require code changes if the library lacks the right exporter.

### All-in-one SaaS agent (Datadog / Dynatrace)

* Good, because setup is minimal — one agent, one destination.
* Good, because the SaaS platform provides dashboards, alerting, and APM out of the box.
* Bad, because it introduces a hard vendor dependency into the application runtime.
* Bad, because SaaS agents are paid services, which is incompatible with the self-hosted academic project scope.
* Bad, because it contradicts the cloud-native, open-source principles established in ADR-0002 and ADR-0003.

## More Information

* [OpenTelemetry project](https://opentelemetry.io/)
* [OpenTelemetry Java instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation)
* [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)
* Related: ADR-0002 (Kubernetes runtime), ADR-0003 (Java/JVM backend), ADR-0007 (LGTM observability backend)
