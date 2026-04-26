# Karta narzędzia: Grafana

## Opis narzędzia

Grafana to platforma do wizualizacji i eksploracji danych obserwacyjnych.
Pełni rolę *single pane of glass* — jednego interfejsu, przez który inżynier może przeglądać metryki (Prometheus), logi (Loki) i ślady (Tempo) bez przełączania się między narzędziami.
Grafana łączy dane z różnych źródeł i pozwala na ich korelację: kliknięcie w anomalię na wykresie metryki może otworzyć logi z dokładnie tego samego przedziału czasu.

## Fragment konfiguracji

```yaml
# provisioning/datasources/datasources.yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
    isDefault: true
    jsonData:
      timeInterval: 15s

  - name: Loki
    type: loki
    url: http://loki:3100
    jsonData:
      derivedFields:
        - name: TraceID
          matcherRegex: '"trace_id":"(\w+)"'
          url: '$${__value.raw}'
          datasourceUid: tempo

  - name: Tempo
    type: tempo
    uid: tempo
    url: http://tempo:3200
    jsonData:
      tracesToLogsV2:
        datasourceUid: loki
        filterByTraceID: true
      serviceMap:
        datasourceUid: prometheus
```

## Dobre nawyki

* **Dashboard as Code:** Dashboardy powinny być przechowywane jako pliki JSON w repozytorium Git i ładowane przez Grafanę za pomocą mechanizmu *provisioning* (katalog `provisioning/dashboards/`). Ręczne tworzenie dashboardów przez UI jest podatne na utratę przy restarcie.
* **Korelacja źródeł danych:** Wartość Grafany jako *single pane of glass* ujawnia się dopiero po skonfigurowaniu łączy między źródłami danych (`derivedFields` w Loki → Tempo, `tracesToLogsV2` w Tempo → Loki). Bez tego korelacja jest ręczna i nieefektywna.
* **Unified Alerting:** Grafana oferuje centralny system alertów (Unified Alerting) działający na regułach PromQL i LogQL. Zamiast konfigurować alerty w Prometheusie i Loki osobno, można zarządzać nimi z poziomu jednego miejsca.
* **Zmienne dashboardu:** Dashboardy powinny używać zmiennych (`$namespace`, `$job`, `$instance`) zamiast zakodowanych wartości, co pozwala na filtrowanie widoku bez duplikowania dashboardów dla każdego środowiska.

## Rola w projekcie

Grafana jest końcowym punktem interfejsu obserwowalności.
Wszystkie dane zbierane przez OTel Collector i przechowywane w Loki, Prometheus i Tempo są dostępne w Grafanie jako spójny obraz stanu systemu.
Przed jej wdrożeniem dane obserwacyjne istnieją w bazach, ale nie ma narzędzia do ich eksploracji i korelacji.
Po wdrożeniu inżynier może w jednym oknie przejść od alertu (metryka) → przez ślad żądania (Tempo) → do konkretnego logu błędu (Loki), zamykając cykl diagnozy incydentu.
