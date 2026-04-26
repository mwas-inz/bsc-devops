# Karta narzędzia: Prometheus

## Opis narzędzia

Prometheus to system monitorowania i baza danych szeregów czasowych (ang. *time-series database*), będący projektem CNCF o statusie *graduated*.
Zbiera metryki poprzez aktywne odpytywanie (ang. *scraping*) endpointów HTTP eksponowanych przez aplikacje i infrastrukturę.
Dane są przechowywane lokalnie i odpytywane za pomocą języka PromQL, który pozwala na agregację, filtrowanie i obliczanie pochodnych metryk.

## Fragment konfiguracji

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'bsc-app-backend'
    static_configs:
      - targets: ['bsc-app-backend:8080']
    metrics_path: /actuator/prometheus

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: "true"
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
```

## Dobre nawyki

* **Metoda RED (Rate, Errors, Duration):** Dla każdego serwisu warto zdefiniować co najmniej trzy podstawowe metryki: liczbę żądań na sekundę (*rate*), odsetek błędów (*errors*) i czas odpowiedzi (*duration*). To minimum pozwalające ocenić stan usługi bez zagłębiania się w logi.
* **Konwencje nazewnictwa:** Metryki powinny używać notacji `snake_case`, a metryki licznikowe (ang. *counter*) powinny kończyć się na `_total` (np. `http_requests_total`). Ułatwia to odczyt i automatyczne narzędzia analizujące metryki.
* **Unikanie wysokiej kardynalności etykiet:** Podobnie jak w Loki, etykiety o wysokiej liczbie unikalnych wartości (np. URL z parametrami, ID użytkownika) powodują eksplozję serii czasowych i degradację wydajności. Etykiety powinny grupować żądania, nie je identyfikować.
* **Service Discovery w Kubernetes:** Zamiast statycznej listy celów, Prometheus może automatycznie wykrywać pody z adnotacją `prometheus.io/scrape: "true"`, co eliminuje konieczność ręcznej aktualizacji konfiguracji przy każdym nowym serwisie.

## Rola w projekcie

Prometheus zbiera metryki z aplikacji (endpoint `/actuator/prometheus` eksponowany przez Micrometer) oraz z infrastruktury Kubernetes (kube-state-metrics, node-exporter).
Przed jego wdrożeniem nie mamy wglądu w liczby żądań, zużycie pamięci, czas odpowiedzi ani kondycję klastra Kubernetes w czasie.
Po wdrożeniu metryki są dostępne w Grafanie i stanowią podstawę do definiowania alertów oraz oceny wydajności systemu.
