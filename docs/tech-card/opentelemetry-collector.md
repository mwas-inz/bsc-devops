# Karta narzędzia: OpenTelemetry Collector

## Opis narzędzia

OpenTelemetry Collector to niezależny od dostawcy komponent pośredniczący (ang. *vendor-agnostic proxy*) w potoku telemetrii.
Odbiera dane z aplikacji (logi, metryki, ślady), przetwarza je i przekazuje do skonfigurowanych backendów.
Dzięki temu aplikacja wysyła dane tylko do Collectora — zmiana backendu wymaga jedynie modyfikacji konfiguracji Collectora, nie kodu aplikacji.

## Fragment konfiguracji

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024
  resource:
    attributes:
      - key: deployment.environment
        value: production
        action: insert

exporters:
  loki:
    endpoint: http://loki:3100/loki/api/v1/push
    default_labels_enabled:
      exporter: false
      job: true
  prometheus:
    endpoint: 0.0.0.0:8889
    namespace: otel
  otlp/tempo:
    endpoint: http://tempo:4317
    tls:
      insecure: true

service:
  pipelines:
    logs:
      receivers: [otlp]
      processors: [batch, resource]
      exporters: [loki]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/tempo]
```

## Dobre nawyki

* **Processor `batch`:** Grupowanie danych przed wysłaniem do backendów znacząco redukuje liczbę połączeń sieciowych i obciążenie CPU po obu stronach.
* **Oddzielenie potoku na trzy pipeline'y:** Każdy z filarów obserwowalności (logi, metryki, ślady) powinien mieć własny pipeline — pozwala to na niezależne skalowanie i wyłączanie poszczególnych kanałów bez wpływu na pozostałe.
* **Processor `resource`:** Wzbogacanie telemetrii o atrybuty środowiskowe (np. `deployment.environment`, `k8s.cluster.name`) na poziomie Collectora eliminuje potrzebę kodowania ich w każdej aplikacji osobno.
* **Uruchamianie w trybie `agent` vs `gateway`:** W środowisku Kubernetes Collector działa najczęściej jako DaemonSet (jeden agent per węzeł), opcjonalnie z centralnym gateway'em przyjmującym dane z agentów.

## Rola w projekcie

OpenTelemetry Collector jest centralnym węzłem potoku telemetrii.
Aplikacja (Java z OTel Java Agent) wysyła logi, metryki i ślady na jeden adres (Collector).
Collector kieruje je dalej do odpowiednich backendów: Loki (logi), Prometheus (metryki), Tempo (ślady).
Pozwala to na całkowitą niezależność aplikacji od konkretnych narzędzi monitoringowych.
