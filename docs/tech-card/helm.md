# Karta narzędzia: Helm

## Opis narzędzia

Helm to menedżer pakietów dla Kubernetes, analogiczny do `apt` czy `brew` w świecie systemów operacyjnych. Pozwala na definiowanie, instalowanie i aktualizowanie złożonych aplikacji Kubernetes jako pojedynczych, wersjonowanych pakietów zwanych **chartami**. Chart to zestaw szablonów YAML sparametryzowanych wartościami z pliku `values.yaml`. Helm śledzi historię wdrożeń jako kolejne **rewizje**, co umożliwia natychmiastowy rollback.

## Fragment konfiguracji

```yaml
# Chart.yaml — metadane pakietu
apiVersion: v2
name: bsc-devops
description: Umbrella chart for the bsc-devops microservices platform
type: application
version: 0.1.0
appVersion: "1.0.0"
```

```yaml
# values.yaml — fragment: parametryzacja serwisu users
users:
  enabled: true
  image:
    repository: "docker.io/mateuszwas/users"
    tag: ""          # nadpisywane przez --set users.image.tag=$SHA w CI
  replicas: 1
  resources:
    requests:
      cpu: "50m"
      memory: "64Mi"
    limits:
      cpu: "500m"
      memory: "256Mi"
```

## Dobre nawyki

* **Umbrella chart:** Grupowanie powiązanych mikroserwisów w jeden chart pozwala wdrożyć cały stos jednym poleceniem `helm install`, zachowując spójność wersji wszystkich komponentów.
* **Parametryzacja przez values:** Wartości specyficzne dla środowiska (tagi obrazów, liczba replik, limity zasobów) powinny być wydzielone do dedykowanych plików `values-prod.yaml`, `values-dev.yaml`, a nie zakodowane na sztywno w szablonach.
* **Wersjonowanie releaseów:** Każda zmiana wprowadzona przez `helm upgrade` tworzy nową rewizję. Polecenie `helm rollback <release> <revision>` natychmiast przywraca poprzedni stan klastra bez ręcznej edycji manifestów.
* **Helpery szablonów (`_helpers.tpl`):** Wspólne etykiety i selektory (`app.kubernetes.io/name`, `app.kubernetes.io/version`) należy definiować jako nazwane szablony w `_helpers.tpl`, aby zapewnić spójność i uniknąć powielania kodu YAML.

## Rola w projekcie

Helm pełni rolę menedżera infrastruktury projektu. Umbrella chart `bsc-devops` opisuje wszystkie 7 komponentów stosu: serwisy `users`, `tasks`, `task-archiver`, `frontend`, bazę PostgreSQL, broker Pulsar oraz Jaeger. Jeden `helm install` wdraża kompletny, skonfigurowany stos na dowolnym klastrze Kubernetes — lokalnym (k3s/minikube) lub chmurowym — bez konieczności ręcznego stosowania dziesiątek plików YAML.
