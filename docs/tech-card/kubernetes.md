# Karta narzędzia: Kubernetes

## Opis narzędzia

Kubernetes (często skracany do K8s) to otwartoźródłowy system do automatyzacji wdrażania, skalowania i zarządzania skonteneryzowanymi aplikacjami. Pełni rolę orkiestratora, który dba o to, aby zdefiniowana liczba instancji aplikacji (podów) była zawsze uruchomiona i dostępna dla użytkowników.

## Fragment konfiguracji (Deployment)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bsc-app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: bsc-app
  template:
    metadata:
      labels:
        app: bsc-app
    spec:
      containers:
      - name: bsc-app
        image: my-registry/bsc-app:1.0.0
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
```

## Dobre nawyki

* **Zarządzanie zasobami:** Obowiązkowe definiowanie `requests` (gwarantowane zasoby) i `limits` (maksymalne zużycie) zapobiega wzajemnemu zakłócaniu się usług (efekt "noisy neighbor").
* **Sondy kondycji (Probes):** Implementacja `livenessProbe` (czy kontener żyje) oraz `readinessProbe` (czy może przyjmować ruch) jest kluczowa dla samonaprawialności klastra i bezprzestojowych wdrożeń (Rolling Updates).
* **Podejście deklaratywne:** Konfiguracja powinna być przechowywana w repozytorium (GitOps) i nakładana za pomocą `kubectl apply`, a nie komend imperatywnych typu `kubectl run`.
* **Bezpieczeństwo (Network Policies):** Domyślne ograniczanie komunikacji między podami do niezbędnego minimum (zasada Zero Trust).

## Rola w projekcie

W ramach projektu Kubernetes stanowi docelowe środowisko uruchomieniowe. O ile Docker pozwala nam stworzyć obraz, o tyle Kubernetes odpowiada za to, by ten obraz "ożył" w klastrze, był dostępny pod konkretnym adresem i automatycznie restartował się w przypadku awarii.
