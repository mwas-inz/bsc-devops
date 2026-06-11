# Karta narzędzia: k3d

## Opis narzędzia

k3d to narzędzie uruchamiające klastry **k3s** (lekkiej, certyfikowanej przez CNCF
dystrybucji Kubernetes) wewnątrz kontenerów Docker. Każdy węzeł klastra jest osobnym
kontenerem, a porty load balancera są mapowane na host już w momencie tworzenia klastra.
Rozwiązuje to główną bolączkę alternatywnych narzędzi lokalnych (np. minikube) —
konieczność uruchamiania dodatkowych procesów tunelujących ruch do zasobów Ingress
(`minikube tunnel`). Dzięki temu każdy zasób Ingress jest dostępny bezpośrednio spod
`http://localhost`, a klaster startuje w czasie poniżej 30 sekund.

## Fragment konfiguracji

```bash
# infrastructure/k3d/cluster-create.sh — tworzenie klastra z mapowaniem portów Ingress
k3d cluster create bsc-devops \
  --agents 2 \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer"
```

## Dobre nawyki

* **Mapowanie portów przy tworzeniu:** Flagi `--port` należy podać w poleceniu
  `k3d cluster create` — nie da się ich dodać do działającego klastra bez jego odtworzenia.
* **Import obrazów lokalnych:** Zamiast wypychać obraz do zewnętrznego rejestru podczas
  iteracji deweloperskiej, należy użyć `k3d image import <obraz> -c <klaster>` — ładuje
  obraz bezpośrednio do containerd w węzłach klastra.
* **Domyślny Ingress — Traefik:** k3s dostarcza Traefik zamiast nginx; manifesty Ingress
  muszą używać `ingressClassName: traefik`.
* **Wielowęzłowość:** Dla testów zbliżonych do produkcji warto dodać agentów
  (`--agents 2`), aby sprawdzić zachowanie schedulera przy ograniczeniach
  `affinity`/`tolerations`.

## Rola w projekcie

k3d stanowi lokalne środowisko deweloperskie i demonstracyjne dla całego stosu
mikroserwisów projektu. Zastąpił minikube (ADR-0015) ze względu na natywne mapowanie
portów Ingress (brak `minikube tunnel`), czas startu klastra poniżej 30 sekund oraz pełną
skryptowalność tworzenia klastra jednym poleceniem CLI. Wbudowany kontroler Ingress
(Traefik) oraz obsługa wielu węzłów pozwalają testować manifesty, polityki sieciowe
i mechanizmy skalowania w warunkach zbliżonych do klastra produkcyjnego (EKS, GKE).
