# Karta narzędzia: Sealed Secrets

## Opis narzędzia

Bitnami Sealed Secrets to mechanizm bezpiecznego przechowywania sekretów Kubernetes
w repozytorium Git. Natywny zasób `Secret` koduje dane jedynie w Base64, co czyni jego
publiczne przechowywanie równoważnym ujawnieniu haseł w jawnym tekście. Sealed Secrets
rozwiązuje ten problem przez **szyfrowanie asymetryczne RSA**: kontroler działający w
przestrzeni `kube-system` generuje parę kluczy i udostępnia klucz publiczny; lokalne
narzędzie `kubeseal` szyfruje `Secret` tym kluczem przed committem, tworząc zasób
`SealedSecret` bezpieczny do umieszczenia w publicznym repozytorium. Klucz prywatny
istnieje wyłącznie w klastrze — bez dostępu do niego zaszyfrowany tekst jest
kryptograficznie bezużyteczny. Kontroler odszyfrowuje `SealedSecret` i materializuje
oryginalny `Secret` w docelowej przestrzeni nazw bez żadnej interwencji operatora.

## Fragment konfiguracji

```bash
# scripts/local/seal-secrets.sh — uszczelnianie tokenu GHCR
DOCKER_AUTH=$(echo -n "mwas-inz:${GHCR_TOKEN}" | base64 -w0)
DOCKER_JSON=$(printf '{"auths":{"ghcr.io":{"auth":"%s"}}}' "$DOCKER_AUTH")

kubectl create secret generic ghcr-docker-config \
    --namespace argocd \
    --from-literal=config.json="$DOCKER_JSON" \
    --dry-run=client -o yaml \
| kubeseal \
    --controller-namespace kube-system \
    --controller-name sealed-secrets \
    --format yaml \
    > gitops/secrets/ghcr-docker-config.sealed.yaml
```

```yaml
# gitops/secrets/ghcr-docker-config.sealed.yaml — struktura zasobu SealedSecret
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: ghcr-docker-config
  namespace: argocd          # powiązanie z przestrzenią nazw (namespace binding)
spec:
  encryptedData:
    config.json: AgB...      # zaszyfrowane RSA kluczem publicznym kontrolera
  template:
    metadata:
      name: ghcr-docker-config
      namespace: argocd
    type: Opaque
```

## Dobre nawyki

* **Namespace binding:** Zaszyfrowany tekst jest ściśle powiązany ze wskazaną przestrzenią
  nazw — `SealedSecret` zaszyfrowany dla `argocd` nie może zostać odszyfrowany w
  `bsc-devops`. Przy uszczelnianiu należy zawsze podać docelową przestrzeń nazw przez
  `--namespace` w `kubectl create secret`.
* **Kopia zapasowa klucza prywatnego:** Przed usunięciem klastra należy wykonać kopię pary
  kluczy kontrolera:
  `kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml`.
  Bez niej wszystkie `SealedSecret` muszą zostać ponownie zaszyfrowane nowym kluczem
  wygenerowanym przez odtworzoną instancję kontrolera.
* **Kolejność bootstrapu:** `SealedSecret` należy aplikować **przed** instalacją ArgoCD —
  kontroler odszyfrowuje je synchronicznie, więc ArgoCD startuje z gotowymi sekretami i
  może natychmiast pobrać chart z rejestru OCI bez ręcznego podawania tokenów.
* **Rotacja tokenów:** Po zmianie tokenu wystarczy ponownie uruchomić
  `scripts/local/seal-secrets.sh` i zaktualizować plik `.sealed.yaml` w Git — kontroler
  automatycznie zastąpi `Secret` w klastrze nową wersją.

## Rola w projekcie

Sealed Secrets umożliwia w pełni beztokenowy bootstrap klastra z repozytorium Git.
Dwa `SealedSecret` są commitowane obok manifestów GitOps:

* **`ghcr-docker-config`** (przestrzeń `argocd`) — konfiguracja Docker uwierzytelniająca
  repo-serwer ArgoCD do pobierania chartów OCI z GHCR; montowana jako wolumin w podzie
  repo-serwera, bo standardowy mechanizm `argocd.argoproj.io/secret-type: repository`
  nie propaguje poświadczeń do stosu Helm OCI.
* **`dockerhub-pull-secret`** (przestrzeń `bsc-devops`) — sekret typu
  `kubernetes.io/dockerconfigjson` uprawniający węzły klastra do pobierania obrazów
  kontenerów z Docker Hub.

Skrypt `scripts/local/seal-secrets.sh` (jednorazowy, przy rotacji tokenów) tworzy oba
zasoby, a `scripts/local/gitops-bootstrap.sh` aplikuje je w odpowiedniej kolejności przy
każdym odtworzeniu klastra.
