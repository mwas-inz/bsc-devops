# Karta narzędzia: Docker

## Opis narzędzia

Docker to platforma służąca do konteneryzacji aplikacji. Pozwala na pakowanie oprogramowania wraz z całym jego środowiskiem uruchomieniowym (bibliotekami, zależnościami i konfiguracją) w lekkie, przenośne kontenery. Dzięki temu aplikacja działa w ten sam sposób niezależnie od maszyny, na której jest uruchamiana.

## Fragment konfiguracji (Dockerfile)

```dockerfile
# Wykorzystanie obrazu bazowego JRE
FROM eclipse-temurin:21-jre-jammy

# Ustawienie katalogu roboczego
WORKDIR /app

# Kopiowanie zbudowanego artefaktu (pliku JAR)
COPY target/app-service.jar app.jar

# Uruchomienie aplikacji
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Dobre nawyki

* **Multi-stage builds:** Stosowanie wieloetapowego budowania pozwala na oddzielenie środowiska kompilacji od środowiska uruchomieniowego, co znacząco redukuje rozmiar obrazu końcowego i zwiększa bezpieczeństwo (brak narzędzi kompilacji w obrazie produkcyjnym).
* **Zasada najniższych uprawnień:** Kontenery domyślnie nie powinny działać jako użytkownik `root`. Należy zdefiniować dedykowanego użytkownika technicznego.
* **Precyzyjne tagowanie:** Unikanie tagu `latest` na rzecz konkretnych wersji (np. semantycznych lub hashów git), co zapewnia powtarzalność wdrożeń.
* **Wykorzystanie .dockerignore:** Wykluczanie zbędnych plików (np. `node_modules`, `.git`, `target/`) z kontekstu budowania przyspiesza proces i zapobiega wyciekom danych wrażliwych.

## Rola w projekcie

W kontekście niniejszego projektu Docker pełni rolę "pakowacza". Przed jego użyciem dysponujemy kodem źródłowym i skompilowanym plikiem JAR. Po procesie budowania obrazu otrzymujemy gotowy do wdrożenia artefakt w postaci obrazu Docker, który można uruchomić w dowolnym środowisku wspierającym konteneryzację.
