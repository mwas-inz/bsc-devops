# Karta narzędzia: Vue 3

## Opis narzędzia

Vue 3 to progresywny framework JavaScript do budowania interfejsów użytkownika.
Wprowadza Composition API — alternatywę dla Options API — które pozwala na
organizowanie logiki komponentu według funkcjonalności, a nie opcji cyklu życia.
Projekt kompilowany jest narzędziem Vite, które wykorzystuje natywne moduły ES
podczas developmentu i Rollup podczas produkcyjnego budowania.

## Fragment konfiguracji (vite.config.ts)

```typescript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
})
```

## Dobre nawyki

- **TypeScript przez `vue-tsc`:** Uruchamianie `vue-tsc --noEmit` przed buildem
  produkcyjnym wychwytuje błędy typów w komponentach `.vue` bez generowania plików.
- **Composition API zamiast Options API:** Lepsza inferencja typów TypeScript
  i łatwiejsze wydzielanie logiki do composables (`use*`).
- **Proxy w Vite podczas developmentu:** Zamiast konfigurować CORS na backendzie,
  warto użyć proxy Vite — zapytania do `/api` są transparentnie przekierowane
  do serwera backendowego.
- **Budowanie wieloetapowe w Dockerze:** Etap `npm ci && vite build` produkuje
  statyczne pliki w `dist/`; docelowy obraz to wyłącznie `nginx` z tymi plikami
  — bez Node.js w środowisku uruchomieniowym.

## Rola w projekcie

Vue 3 pełni rolę cienkiej warstwy prezentacji (*thin client*) nad REST API
mikroserwisów backendowych. Interfejs umożliwia przeglądanie i zarządzanie
zadaniami, demonstrując pełną ścieżkę żądania: przeglądarka → nginx (ingress) →
serwis users/tasks (Quarkus native) → PostgreSQL. Warstwa frontendowa jest
wdrażana jako osobny mikroserwis w klastrze Kubernetes z własnym pipeline CI/CD,
analogicznie do serwisów backendowych.
