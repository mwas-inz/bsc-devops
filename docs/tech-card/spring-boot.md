# Karta narzędzia: Spring Boot

## Opis narzędzia

Spring Boot to popularny framework do tworzenia aplikacji w języku Java, który upraszcza proces konfiguracji i wdrażania. Pozwala na tworzenie samodzielnych, produkcyjnych aplikacji (standalone), które "po prostu działają", bez konieczności zewnętrznego serwera aplikacji (posiada wbudowany serwer, np. Tomcat).

## Fragment konfiguracji (application.yml)

```yaml
spring:
  application:
    name: bsc-service
  datasource:
    url: jdbc:postgresql://localhost:5432/db
    driver-class-name: org.postgresql.Driver

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
```

## Dobre nawyki

* **Zewnętrzna konfiguracja:** Stosowanie zmiennych środowiskowych i profili (np. `application-prod.yml`) zamiast hardkodowania wartości. Pozwala to na zachowanie zasady "build once, run anywhere".
* **Spring Boot Actuator:** Obowiązkowe włączenie punktów końcowych `/health` i `/metrics`, co umożliwia monitoring aplikacji przez Kubernetes i Prometheusa.
* **Warstwowe pliki JAR (Layered JARs):** Wykorzystanie formatu warstwowego w obrazach Docker pozwala na cache'owanie bibliotek i szybsze przesyłanie obrazu, gdy zmienia się tylko kod biznesowy.
* **Wstrzykiwanie przez konstruktor:** Preferowanie wstrzykiwania zależności przez konstruktor zamiast pola `@Autowired`, co ułatwia testowanie jednostkowe i gwarantuje niemutowalność komponentów.

## Rola w projekcie

Spring Boot stanowi fundament dla głównych usług biznesowych projektu. Zapewnia on dojrzałe mechanizmy integracji z bazami danych, bezpieczeństwo (Spring Security) oraz łatwość wystawiania punktów końcowych monitoringu (Actuator), co jest niezbędne do poprawnej współpracy z systemami typu Prometheus wewnątrz klastra Kubernetes.
