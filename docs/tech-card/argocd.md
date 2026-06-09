# Karta narzędzia: ArgoCD

## Opis narzędzia

ArgoCD to deklaratywny kontroler GitOps dla Kubernetes, będący projektem CNCF o statusie
*graduated*. Działa w modelu **pull-based**: nasłuchuje zmian w repozytorium Git (lub
rejestrze OCI) i automatycznie synchronizuje stan klastra do zdefiniowanego tam stanu
docelowego — bez konieczności wywoływania `kubectl` z poziomu CI/CD. Centralną abstrakcją
jest zasób `Application`, który wiąże źródło (chart Helm, katalog manifestów, Kustomize)
z docelowym klastrem i przestrzenią nazw. Wbudowany interfejs webowy pozwala w czasie
rzeczywistym obserwować drzewo zasobów aplikacji, status synchronizacji oraz historię
wdrożeń.

## Fragment konfiguracji

```yaml
# gitops/application.yaml — ArgoCD Application CRD dla projektu bsc-devops
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bsc-devops
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ghcr.io/mateuszwas/charts   # OCI Helm registry (GHCR)
    chart: bsc-devops
    targetRevision: "0.5.0"
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc  # lokalny klaster k3d
    namespace: bsc-devops
  syncPolicy:
    automated:
      prune: true      # usuwa zasoby usunięte z charta
      selfHeal: true   # cofa ręczne zmiany niezgodne z Gitem
    syncOptions:
      - CreateNamespace=true
```

## Dobre nawyki

* **Automated sync z `selfHeal`:** Włączenie `selfHeal: true` gwarantuje, że każda ręczna
  zmiana w klastrze (np. przez `kubectl edit`) zostanie natychmiast cofnięta — klaster jest
  zawsze zgodny z tym, co opisuje Git.
* **`prune: true` z rozwagą:** Automatyczne usuwanie zasobów odłączonych od charta skraca
  dług konfiguracyjny, ale wymaga pewności, że wszystkie zasoby są faktycznie zarządzane
  przez ArgoCD — zasoby tworzone ręcznie mogą zostać niespodziewanie usunięte.
* **Application CRD w Git:** Plik `gitops/application.yaml` powinien być przechowywany
  w repozytorium obok charta Helm. Dzięki temu cały opis dostawy — od artefaktu po klaster
  docelowy — jest wersjonowany i audytowalny.
* **Wersjonowanie `targetRevision`:** Używanie konkretnego numeru wersji charta (nie `*`
  ani `latest`) zapewnia powtarzalność wdrożeń i pełną historię zmian w `Application`.

## Rola w projekcie

ArgoCD zamyka pętlę CI/CD projektu: GitHub Actions buduje obraz, publikuje chart do GHCR,
a ArgoCD automatycznie wykrywa nową wersję charta i synchronizuje klaster k3d. Zasób
`Application` opisany w `gitops/application.yaml` wskazuje na chart `bsc-devops` w GHCR
(skonfigurowany w ADR-0012) i celuje w lokalny klaster k3d (ADR-0015). Wbudowany interfejs
webowy ArgoCD dostarcza wizualizację drzewa zasobów bezpośrednio przydatną jako materiał
ilustracyjny w pracy dyplomowej.
