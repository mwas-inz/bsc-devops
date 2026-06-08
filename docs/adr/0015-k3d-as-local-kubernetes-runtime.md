# k3d as Local Kubernetes Runtime

* Status: accepted
* Date: 2026-06-08
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The project requires a local Kubernetes cluster for development, integration testing, and thesis demonstrations (see ADR-0002). The chosen tool must be fast to provision, require minimal configuration, and expose Ingress traffic on `localhost` without manual workarounds. The initial implementation used **minikube**, but its Docker-driver mode required running `minikube tunnel` in a separate terminal to reach Ingress from the host, and startup times were high. A lighter alternative was needed.

## Decision Drivers

* **Developer experience:** Cluster creation must be fast (< 30 s) and Ingress must be reachable at `localhost` out of the box.
* **No VM overhead:** The tool should run entirely in Docker to avoid hypervisor dependencies on Linux, macOS, and Windows.
* **Production topology parity:** Ability to spin up multi-node clusters (server + agents) to test scheduling behaviour closer to real environments.
* **Built-in Ingress:** Ingress controller should be available without manual addon management.
* **CNCF alignment:** Prefer tools built on production-grade, CNCF-graduated runtimes.

## Considered Options

* **k3d** — thin Docker wrapper around k3s; creates clusters as Docker containers with port-mapping to localhost.
* **minikube** — mature local Kubernetes tool; supports multiple drivers (VM, Docker, Podman); Ingress is an addon.
* **kind** (Kubernetes in Docker) — runs clusters as Docker containers; no built-in Ingress controller or load-balancer.
* **Docker Desktop (Kubernetes)** — single-node cluster bundled with Docker Desktop; not scriptable and tied to a GUI application.

## Decision Outcome

Chosen option: **k3d**, because it eliminates the tunnel workaround through Docker port-mapping at cluster creation time, starts in under 30 seconds, and ships with a built-in Traefik Ingress controller via k3s — with no addon management required.

Cluster is created with:

```sh
k3d cluster create bsc-devops \
  --agents 1 \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer"
```

This maps host port 80 to the k3d load-balancer, making every Ingress resource immediately reachable at `http://localhost` without any additional steps.

### Consequences

* Good, because Ingress is reachable at `http://localhost` immediately — no tunnel, no IP lookup.
* Good, because cluster creation takes ~20 s versus ~2 min for minikube with the Docker driver.
* Good, because multi-node clusters (`--agents N`) are trivial, enabling realistic scheduling tests.
* Good, because k3s is a CNCF-graduated, production-used distribution (used by Rancher, K3OS, etc.).
* Good, because `k3d image import <image> -c bsc-devops` loads locally-built images without a registry.
* Bad, because k3s omits some rarely-used Kubernetes APIs (e.g., cloud-provider-specific controllers), which is irrelevant for this project's scope.
* Bad, because the default Ingress controller is Traefik rather than nginx; existing manifests using `ingressClassName: nginx` must be updated to `ingressClassName: traefik`.

## Pros and Cons of the Options

### k3d

* Good, because Docker port-mapping makes Ingress reachable on `localhost` — no tunnel command needed.
* Good, because cluster creation is fast (~20 s) and fully scriptable with a single CLI call.
* Good, because Traefik Ingress controller is included with k3s — nothing to install separately.
* Good, because `k3d image import` loads images directly into the cluster without pushing to a registry.
* Bad, because k3s is not full upstream Kubernetes; some alpha/cloud-provider APIs are absent.

### minikube

* Good, because it supports multiple drivers (Docker, KVM, Hyper-V, VirtualBox) for flexibility.
* Good, because the addon system provides optional components (metrics-server, registry, etc.).
* Bad, because the Docker driver requires `minikube tunnel` running in a separate process to expose Ingress on `localhost`.
* Bad, because startup is slow (~1–2 min) and resource usage is higher under VM drivers.
* Bad, because enabling Ingress requires an explicit `minikube addons enable ingress` step.

### kind

* Good, because it is the official Kubernetes SIG tool for CI cluster testing.
* Good, because clusters start quickly and integrate well with GitHub Actions.
* Bad, because it ships with no Ingress controller or load-balancer — both require manual installation.
* Bad, because NodePort access from the host requires extra port-mapping configuration.

### Docker Desktop (Kubernetes)

* Good, because zero setup on machines already running Docker Desktop.
* Bad, because it is a single-node cluster with no control over the Kubernetes version.
* Bad, because it is tied to the Docker Desktop GUI application and cannot be scripted.
* Bad, because cluster lifecycle (reset, delete) is performed through a UI, not a CLI.

## More Information

* k3d documentation: [https://k3d.io/stable/](https://k3d.io/stable/)
* k3s (CNCF project): [https://k3s.io/](https://k3s.io/)
* Related: ADR-0002 (Kubernetes as runtime environment), ADR-0012 (Helm as package manager)
