# Finalny Plan Pracy Inżynierskiej: Portal do zarządzania zadaniami

## I. Fundamenty Teoretyczne

* **Twelve-Factor App** ✅
  * Zestaw 12 zasad budowania skalowalnych aplikacji SaaS — punkt odniesienia dla mikroserwisów i DevOps.

* **DevOps** ✅
  * Historia i geneza (Debois, Forsgren, Humble, Kim, Willis).
  * Kluczowe wartości i kultura; model CALMS (Culture, Automation, Lean, Measurement, Sharing).
  * Metryki DORA: *Deployment Frequency*, *Lead Time for Changes*, *Change Failure Rate*, *Time to Restore Service*.
  * Pętla ciągłego doskonalenia — 8 etapów (Plan → Code → Build → Test → Release → Deploy → Operate → Monitor).
  * Specjalizacje: GitOps, DevSecOps, SRE, Platform Engineering i inne (omówione kontekstowo).

* **Cloud computing** ✅
  * Definicja NIST; typy chmur: publiczna, prywatna, hybrydowa, społecznościowa.
  * Wiodący dostawcy: AWS, Azure, GCP i poboczni.

* **Cloud Native** 🔲
  * Definicje i filary Cloud Native; Cloud computing vs Cloud Native.
  * Cloud Native Computing Foundation — landscape, standardy, certyfikaty.

* **Kubernetes** 🔲
  * Pozycja rynkowa i główne zalety (deklaratywność, self-healing, cloud-agnostic).
  * Alternatywy i zarządzane klastry (GKE, EKS, AKS) -> łatwość deploymentu w chmurze i lokalnie (k3d, kind).

## II. Implementacja Systemu

> Format każdego etapu: karta narzędzia (opis + fragment konfiguracji + dobre nawyki + rola w projekcie).
> Aplikacja jest pretekstem, nie tematem — interesuje nas generyczny proces wdrożenia.

* **Plan & Code**
  * Zarządzanie wymaganiami (Jira), kontrola wersji (GitHub).
  * Aplikacja: serwis klient-serwer (Java backend, React frontend) w architekturze mikroserwisowej. Szczegóły implementacyjne poza zakresem — skupiamy się na procesie wdrożenia.
  * Środowisko lokalne: *k3d* jako lokalny klaster Kubernetes.

* **Build**
  * Budowanie artefaktów: Gradle.
  * Konteneryzacja: Dockerfile → obraz Docker (uzasadnienie wyboru w ADR: Dockerfile vs Jib vs Paketo Buildpacks).
  * Automatyzacja: GitHub Actions jako pipeline CI.
  * *Shift Left Security*: skanowanie obrazu (Trivy) i podpisywanie (Cosign) jako etap pipeline CI — bezpieczeństwo przesuniete możliwie wcześnie w cyklu wytwarzania.

* **Test**
  * Testy jednostkowe i integracyjne: JUnit osadzony w pipeline CI.

* **Release**
  * Rejestr obrazów: DockerHub.
  * Pakietowanie dla Kubernetes: Helm + ArtifactHub.

* **Deploy**
  * GitOps: ArgoCD lub Flux w architekturze *App of Apps*.
  * Provisioning infrastruktury: Terraform.

* **Operate**
  * Środowisko docelowe: Kubernetes (jedyne omawiane środowisko uruchomieniowe).

## III. Obserwowalność (Observability)

> Standard: OpenTelemetry jako wspólny mianownik — jeden Collector, jeden SDK, niezależność od backendu.
> Stos: LGTM (Loki, Grafana, Tempo, Prometheus) — Grafana jako *single pane of glass*.

* **Logi** — Logback/Log4j (format JSON) → OTel Collector → Loki → Grafana
* **Metryki** — Micrometer + OTel bridge → Prometheus → Grafana
* **Ślady (Traces)** — OTel Java Agent (auto-instrumentation, zero zmian w kodzie) → Tempo → Grafana

## IV. Analiza i Wnioski

* Uzasadnienie wyborów inżynierskich w kontekście potrzeb projektu i akademickich ADR-ów.
* Ocena przyjętego podejścia DevOps end-to-end na przykładzie jednej aplikacji.

## V. Podsumowanie

* *Lessons learned*: wyzwania w konfiguracji GitOps i Observability.
* Wnioski inżynierskie i kierunki dalszego rozwoju.

---

## Brudnopis — kwestie do rozstrzygnięcia

> Poniższe punkty wymagają decyzji przed rozmową z promotorem lub przed implementacją.

---

> **Rozstrzygnięte (2026-04-26):**
>
> * ~~AWS~~ → Kubernetes jako jedyne środowisko uruchomieniowe.
> * ~~Supply Chain Security jako osobny rozdział~~ → Shift Left w etapie Build (Trivy + Cosign w pipeline CI).
> * ~~Porównanie LGTM vs ELK~~ → LGTM jako jedyny omawiany stos, bez studium porównawczego.
> * ~~FinOps, HPA/VPA, Platform Engineering/Backstage~~ → poza zakresem pracy.
> * ~~Porównanie strategii konteneryzacji~~ → Dockerfile jako wybór; uzasadnienie w ADR.
> * ~~Ansible~~ → poza zakresem pracy.
> * ~~Frontend jako osobny etap~~ → aplikacja istnieje, opis koncepcyjny bez szczegółów implementacyjnych.
> * ~~Observability ADR~~ → ADR-0006 (OpenTelemetry) i ADR-0007 (LGTM) przyjęte; karty narzędzi gotowe.
