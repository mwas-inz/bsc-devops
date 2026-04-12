# Choose Kubernetes as Main Runtime Environment

* Status: accepted
* Date: 2026-04-12
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The bsc-devops project is an engineering thesis focused on modern DevOps and cloud-native SDLC practices. To demonstrate these principles, we need a robust, scalable, and industry-standard container orchestration platform. The runtime environment must support declarative configuration, self-healing capabilities, and a rich ecosystem of tools for CI/CD, GitOps, and observability.

## Decision Drivers

* **Cloud-Native Standards:** Adherence to the 12-factor app methodology and modern infrastructure practices.
* **Portability:** The ability to run the same configuration locally (e.g., via Minikube/Kind) and in major cloud providers (AWS, Azure, GCP).
* **Ecosystem Compatibility:** Seamless integration with standard DevOps tools like Helm, Terraform, and GitOps controllers (e.g., ArgoCD or Flux).
* **Scalability and Resilience:** Support for automated scaling, rolling updates, and self-healing of services.

## Considered Options

* **Kubernetes (K8s):** The industry-standard container orchestration platform.
* **Docker Compose:** A simpler tool for defining and running multi-container Docker applications.
* **Serverless / Function-as-a-Service (FaaS):** Platforms like AWS Lambda or Google Cloud Functions.
* **Traditional Virtual Machines (VMs):** Managing services directly on virtualized hardware.

## Decision Outcome

Chosen option: **Kubernetes (K8s)**, because it provides the most comprehensive set of features required to demonstrate a complete, modern DevOps lifecycle. It is the de facto standard for cloud-native applications and offers the necessary abstractions for infrastructure-as-code and GitOps workflows.

### Consequences

* **Good:** High industry relevance and alignment with the thesis topic (Cloud Native & DevOps).
* **Good:** Strong support for automated deployments, scaling, and observability.
* **Good:** Excellent portability across different cloud environments and local development setups.
* **Bad:** Increased complexity compared to simpler alternatives like Docker Compose.
* **Bad:** Higher resource overhead, requiring more significant hardware/cloud resources even for small deployments.

## Pros and Cons of the Options

### Kubernetes (K8s)

* Good, because it is the industry standard for container orchestration.
* Good, because it supports advanced deployment patterns (canary, blue-green).
* Good, because it has a massive ecosystem of supporting tools (Helm, Prometheus, etc.).
* Bad, because it has a steep learning curve and high operational complexity.

### Docker Compose

* Good, because it is extremely simple to set up and run locally.
* Bad, because it lacks advanced orchestration features like self-healing and auto-scaling.
* Bad, because it is not suitable for complex, production-like production environments.

### Serverless / FaaS

* Good, because it minimizes infrastructure management overhead.
* Bad, because it often leads to vendor lock-in and can be difficult to test locally.
* Bad, because it may not be suitable for all types of services (e.g., long-running tasks).

### Traditional Virtual Machines (VMs)

* Good, because of complete control over the operating system and hardware.
* Bad, because it lacks the agility and efficiency of container-based orchestration.
* Bad, because managing VM images and configurations at scale is more difficult.

## More Information

* Kubernetes Documentation: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)
* CNCF Cloud Native Landscape: [https://landscape.cncf.io/](https://landscape.cncf.io/)
