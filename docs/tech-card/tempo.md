# Karta narzędzia: Tempo

## Opis narzędzia

Tempo to backend do przechowywania i odpytywania śladów rozproszonych (ang. *distributed traces*) stworzony przez Grafana Labs.
Ślad (ang. *trace*) to zapis podróży jednego żądania przez wszystkie serwisy systemu — od momentu wejścia do API aż do odpowiedzi zwróconej do klienta.
Tempo jest zaprojektowane jako magazyn *trace-only*, celowo bez indeksowania treści śladów, co czyni je bardzo oszczędnym w zasobach.
Odpytywanie odbywa się za pomocą języka TraceQL lub bezpośrednio po *trace ID*, który można pobrać z logów lub metryk.

## Fragment konfiguracji

```yaml
# tempo-config.yaml
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318

ingester:
  max_block_duration: 5m

compactor:
  compaction:
    block_retention: 48h

storage:
  trace:
    backend: local
    local:
      path: /var/tempo/blocks
    wal:
      path: /var/tempo/wal

metrics_generator:
  registry:
    external_labels:
      source: tempo
  storage:
    path: /var/tempo/generator/wal
    remote_write:
      - url: http://prometheus:9090/api/v1/write
        send_exemplars: true
```

## Dobre nawyki

* **Propagacja Trace ID do logów:** Kluczową korzyścią ze śladów jest możliwość przejścia od logu błędu do pełnego śladu żądania. OTel Java Agent automatycznie wstrzykuje `trace_id` i `span_id` do logów — należy upewnić się, że format logów (JSON) zawiera te pola, a Grafana ma skonfigurowane łącze między Loki a Tempo.
* **Strategia próbkowania (sampling):** Zbieranie 100% śladów w systemie produkcyjnym generuje duże koszty. Dla projektów akademickich próbkowanie *head-based* (np. 10% żądań) jest wystarczające. W Tempo można też zastosować *tail-based sampling* dla selektywnego zbierania śladów błędów.
* **Metrics Generator:** Tempo może automatycznie generować metryki RED (Rate, Errors, Duration) ze śladów i eksportować je do Prometheusa. Pozwala to uniknąć duplikowania instrumentacji, gdy ślady są jedynym źródłem danych.

## Rola w projekcie

Tempo odbiera ślady generowane przez OTel Java Agent uruchomiony w aplikacji i przekazywane przez OTel Collector.
Przed jego wdrożeniem nie widzimy, jak żądanie przepływa przez serwisy, gdzie pojawiają się opóźnienia ani który serwis jest wąskim gardłem.
Po wdrożeniu w Grafanie można przejść od wykresu metryki (wzrost czasu odpowiedzi) bezpośrednio do konkretnego wolnego śladu, a stamtąd do logów z tego samego żądania — zamykając pętlę obserwowalności.
