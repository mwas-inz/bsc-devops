# Karta narzędzia: Loki

## Opis narzędzia

Loki to system agregacji i przechowywania logów stworzony przez Grafana Labs, zaprojektowany z myślą o środowiskach Kubernetes.
W odróżnieniu od Elasticsearch, Loki nie indeksuje treści logów — indeksuje wyłącznie **etykiety** (ang. *labels*), takie jak nazwa poda, namespace czy środowisko.
Dzięki temu jest znacznie bardziej wydajny pamięciowo i obliczeniowo przy zbliżonej możliwości filtrowania logów.

## Fragment konfiguracji

```yaml
# loki-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
  chunk_idle_period: 5m
  max_chunk_age: 1h

schema_config:
  configs:
    - from: 2024-01-01
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  tsdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/index_cache
  filesystem:
    directory: /loki/chunks

limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h
```

## Dobre nawyki

* **Ograniczaj liczbę etykiet (label cardinality):** Każda unikalna kombinacja wartości etykiet tworzy osobny strumień logów. Etykiety o wysokiej kardynalności (np. `user_id`, `request_id`) drastycznie zwiększają zużycie pamięci i powinny trafiać do treści logu, nie do etykiet.
* **Strukturalne logowanie (JSON):** Aplikacja powinna wypisywać logi w formacie JSON na `stdout`. Loki przechowuje je jako tekst, ale Grafana potrafi parsować pola JSON, co umożliwia filtrowanie po zawartości (np. `| json | level="error"`).
* **Spójne etykiety z Prometheusem:** Stosowanie tych samych nazw etykiet w Loki i Prometheus (np. `job`, `instance`, `namespace`) ułatwia korelację logów z metrykami w Grafanie bez ręcznego dopasowywania.

## Rola w projekcie

Loki odbiera logi aplikacji przesyłane przez OpenTelemetry Collector i przechowuje je z etykietami kontekstowymi (nazwa serwisu, środowisko, namespace Kubernetes).
Przed użyciem Loki dysponujemy strumieniem logów jedynie na `stdout` kontenera.
Po jego wdrożeniu logi są centralnie agregowane, przeszukiwalne za pomocą języka LogQL i dostępne w Grafanie obok metryk i śladów dla tej samej aplikacji.
