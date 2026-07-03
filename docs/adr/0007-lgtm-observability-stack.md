# Adopt LGTM as the Observability Backend Stack

* Status: accepted
* Date: 2026-04-26
* Decision-makers: Mateusz Waś
* Consulted:
* Informed:

## Context and Problem Statement

Having adopted OpenTelemetry as the instrumentation standard (ADR-0006), concrete backends must be chosen for each of the three observability pillars: log storage and querying, metrics storage and querying, and distributed trace storage and querying.
A unified visualization layer is also needed to correlate data across all three pillars.
The chosen backends must be self-hosted, open-source, and compatible with Kubernetes and the OpenTelemetry Collector.

## Decision Drivers

* **Unified visualization:** A single UI to navigate logs, metrics, and traces simultaneously reduces context switching during incident investigation.
* **OpenTelemetry compatibility:** All backends must natively accept telemetry from the OTel Collector (ADR-0006).
* **Kubernetes-native deployment:** Components must be deployable as standard Kubernetes workloads, preferably via Helm.
* **Open source and self-hosted:** Must be runnable without a paid SaaS subscription for the academic project scope.
* **Ecosystem coherence:** Preferring components from the same ecosystem reduces integration overhead.

## Considered Options

* **LGTM** — Loki (logs) + Grafana (visualization) + Tempo (traces) + Prometheus / Mimir (metrics): all from the Grafana Labs ecosystem.
* **ELK / EFK stack** — Elasticsearch or OpenSearch (logs + search) + Logstash or Fluentd (collection) + Kibana (visualization), with Prometheus for metrics separately.
* **Managed SaaS** — Grafana Cloud, Datadog, or New Relic as fully managed all-in-one platforms.

## Decision Outcome

Chosen option: **LGTM (Loki + Grafana + Tempo + Prometheus)**, because all four components are natively integrated through Grafana, each accepts OpenTelemetry data via the OTel Collector, and the stack is deployable on Kubernetes using official Helm charts.
Grafana serves as the single visualization layer for all three pillars, enabling correlated investigation (e.g., jumping from a trace to its corresponding logs).

### Consequences

* Good, because Grafana natively integrates Loki, Tempo, and Prometheus as datasources, enabling cross-pillar correlation in a single UI.
* Good, because all components have official Helm charts maintained by Grafana Labs, simplifying Kubernetes deployment.
* Good, because Loki and Tempo are resource-efficient compared to Elasticsearch — better suited for a single-node academic cluster.
* Good, because Prometheus is the CNCF standard for metrics, with a large ecosystem of exporters and recording rules.
* Bad, because the LGTM stack consists of four separately managed components, each with its own configuration and operational concerns.
* Bad, because Loki's label-based indexing model (as opposed to full-text indexing in Elasticsearch) requires discipline in structuring log labels to avoid high cardinality issues.

## Pros and Cons of the Options

### LGTM (Loki + Grafana + Tempo + Prometheus)

* Good, because all four tools are first-class citizens in the Grafana ecosystem — datasource plugins are maintained by the same team.
* Good, because Loki is designed for Kubernetes log collection (pod labels become Loki labels naturally via Promtail or OTel).
* Good, because Tempo supports TraceQL, enabling expressive distributed trace queries.
* Good, because Prometheus is the de facto standard for Kubernetes metrics, with native integration for kube-state-metrics and node-exporter.
* Bad, because Loki does not support full-text search — it only indexes log labels, not log content.
* Bad, because Prometheus has limited long-term storage; Mimir or Thanos would be needed for production-grade retention (out of scope for this project).

### ELK / EFK Stack

* Good, because Elasticsearch supports full-text search over log content, which is powerful for ad-hoc investigation.
* Good, because Kibana provides a mature log exploration UI with advanced filtering.
* Bad, because Elasticsearch is resource-intensive (high JVM heap requirements), making it impractical for a single-node academic cluster.
* Bad, because the ELK stack does not natively include a tracing backend — an additional component (Jaeger, Zipkin) would be needed.
* Bad, because Kibana and Grafana would be needed simultaneously for metrics and logs respectively, preventing a single pane of glass.

### Managed SaaS (Grafana Cloud / Datadog / New Relic)

* Good, because zero infrastructure management is required — all components are operated by the vendor.
* Good, because free tiers exist for small-scale projects (Grafana Cloud free tier).
* Bad, because the project would depend on external services, which conflicts with the self-hosted Kubernetes scope of this thesis.
* Bad, because SaaS services may introduce data residency concerns and require API key management.

## More Information

* [Grafana Loki](https://grafana.com/oss/loki/)
* [Grafana Tempo](https://grafana.com/oss/tempo/)
* [Prometheus](https://prometheus.io/)
* [Grafana](https://grafana.com/oss/grafana/)
* [kube-prometheus-stack Helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
* Related: ADR-0002 (Kubernetes runtime), ADR-0006 (OpenTelemetry standard)
