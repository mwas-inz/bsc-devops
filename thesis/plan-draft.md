# Finalny Plan Pracy Inżynierskiej: Portal do zarządzania zadaniami

## I. Fundamenty Teoretyczne

* **Nowoczesne systemy aplikacyjne**
  * Filary *Cloud Native* i architektura *Twelve-Factor App*.
  * *Cloud Native Maturity Model* (CNCF) jako punkt odniesienia.
  * **Modele dojrzałości DevOps (Capability/Maturity Models):** Analiza etapów rozwoju organizacji (od *ad-hoc* do *fully automated/optimized*) oraz kluczowych zdolności technicznych i kulturowych wpływających na wydajność zespołu (DORA metrics).

* **Strategie wytwarzania i operacji (DevOps vs SRE vs Platform Engineering)**
  * GitOps: Analiza wzorców *Pull vs Push*, *drift detection* i *reconciliation*.
  * Ewolucja od klasycznego DevOps do Platform Engineering (Internal Developer Portals).

* **Cykl życia oprogramowania (SDLC)**
  * Dojrzałość procesów CI/CD i wyzwania mikroserwisów (*Dependency Hell*, wersjonowanie API).

## II. Implementacja Systemu (Kubernetes-first)

* **Planowanie i rozwój (Plan & Code)**
  * Zarządzanie wymaganiami (Jira), kontrola wersji (GitHub).
  * **Architektura:** Java (Quarkus lub SpringBoot), React.
  * **Wytwarzanie aplikacji:** Strategie konteneryzacji (Cloud Native Buildpacks vs Dockerfile), optymalizacja obrazów (Native images).
  * **DX (Developer Experience):** Środowisko lokalne (*minikube*, *kind* lub *k3s*), workflow deweloperski.

* **Automatyzacja i GitOps (Build, Test, Release)**
  * Proces CI/CD: GitHub Actions, Gradle, JUnit.
  * GitOps: ArgoCD lub Flux w architekturze *App of Apps* (wzorzec zarządzania mikroserwisami).
  * *Supply Chain Security*: Skanowanie obrazów w procesie CI/CD (Trivy/Clair), podpisywanie (Cosign/Kyverno).

* **Produkcyjna gotowość (Orchestration & Security)**
  * *Admission Controllers*: Kyverno lub OPA.
  * Segmentacja sieci: *NetworkPolicies*.
  * Niezawodność: *Liveness* i *Readiness probes* (fundament *self-healing*).
  * *SecurityContexts*: Zabezpieczanie kontenerów.

## III. Obserwowalność (Observability)

* **Standardy zbierania danych**
  * *OpenTelemetry*: Instrumentacja automatyczna i manualna jako serce obserwowalności.

* **Studium porównawcze staków (LGTM vs ELK)**
  * *LGTM* (Loki, Grafana, Tempo, Mimir/Prometheus): Nowoczesny cel.
  * *ELK* (Elasticsearch, Logstash, Kibana): Historyczne studium przypadku.

* **Analiza inżynierska**
  * Porównanie wydajności i kosztów (CPU, RAM, Storage).
  * Definicja SLO/SLI (np. czas odpowiedzi < 200ms w 99% przypadków).
  * Alerting: Integracja z OpsGenie.

## IV. Analiza, FinOps i Rozwój

* **Analiza decyzji inżynierskich**
  * Uzasadnienie wyborów (dlaczego wybrano dane narzędzia) w kontekście potrzeb biznesowych.

* **Optymalizacja kosztów (FinOps)**
  * Wdrożenie *Pod Autoscaling* (HPA, VPA) i analiza ich wpływu na koszty w chmurze (np. AWS).

* **Kierunki rozwoju**
  * Hybrydowe modele zarządzania (rola Ansible).
  * Przekształcenie systemu w platformę (wzorce *Internal Developer Portal* - Backstage).

## V. Podsumowanie i Wnioski

* *Lessons learned*: Wyzwania w konfiguracji obserwowalności i GitOps.
* Ewaluacja: GitOps vs Klasyczny DevOps.
* Wnioski inżynierskie i ocena końcowa systemu.
