# Karta narzędzia: Quarkus

## Opis narzędzia

Quarkus to nowoczesny stos technologiczny Java, określany jako "Supersonic Subatomic Java". Został zaprojektowany z myślą o środowiskach natywnych dla chmury (Cloud Native) oraz kontenerach i platformach typu serverless. Charakteryzuje się bardzo niskim zużyciem pamięci oraz błyskawicznym czasem uruchamiania.

## Fragment konfiguracji (application.properties)

```properties
# Konfiguracja natywnego obrazu
quarkus.package.type=native
quarkus.native.container-build=true

# Konfiguracja bazy danych (Dev Services)
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=quarkus
quarkus.datasource.password=quarkus
```

## Dobre nawyki

* **Testowanie natywne:** Zawsze należy uruchamiać testy w trybie natywnym (`@NativeImageTest`), aby upewnić się, że optymalizacje czasu kompilacji nie usunęły elementów wymaganych przez refleksję.
* **Dev Services:** Wykorzystanie automatycznego podnoszenia baz danych i brokerów w kontenerach podczas developmentu zapewnia spójność środowiska u wszystkich programistów.
* **Umiar w refleksji:** Quarkus dąży do eliminacji refleksji. Należy preferować rozwiązania wspierające indeksowanie Jandex i unikać bibliotek, które intensywnie korzystają z dynamicznego ładowania klas.
* **Continuous Testing:** Korzystanie z trybu ciągłego testowania w konsoli pozwala na natychmiastową informację zwrotną o błędach w trakcie pisania kodu.

## Rola w projekcie

Quarkus jest wykorzystywany do budowy wydajnych mikroserwisów, które muszą cechować się wysoką gęstością upakowania w klastrze Kubernetes. Dzięki niemu aplikacje w projekcie zużywają minimalną ilość zasobów, co przekłada się na niższe koszty infrastruktury i szybszą reakcję na zdarzenia (skalowanie).
