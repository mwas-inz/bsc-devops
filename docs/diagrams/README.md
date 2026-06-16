# Diagrams

Architecture and flow diagrams for the thesis and related documentation.
This file is the working plan and authoring guide for the diagram set.
All ten diagrams are authored as Mermaid sources (see [Source files](#source-files)) with **Polish labels** (the thesis figure language; technical and product names, identifiers, and config keys are kept as-is) and exported to `thesis/img/`. They parse and render cleanly. Excalidraw polish is an optional remaining step.

## Authoring approach

The diagram set follows a **hybrid** model so it stays consistent with the thesis "Everything as Code" argument:

- **Mermaid is the canonical source.** Each diagram is authored as a `.mmd` file under version control — diffable, reviewable, reproducible.
- **Excalidraw is the polish/render layer (optional).** Where a hand-drawn, presentation-grade figure is wanted, the Mermaid source is imported into Excalidraw, refined, and exported.
- **Theme.** Every chart sets `config: theme: neo` in its frontmatter (Mermaid's `neo` theme — a clean white/black base suited to print). Per-node `classDef` colors override it where semantic grouping helps (services, data stores, security, GitOps). Note: the Mermaid CLI `-t` flag rejects `neo` (its whitelist is stale); the theme must be set via frontmatter `config`, which is what these files do.

This keeps a text source of truth in Git while still allowing a more visual final asset.
A `.excalidraw` file is JSON but is *drawn*, not *authored*, so it is not treated as the source of truth on its own.

## Tooling and workflow (Excalidraw)

Recommendations for the optional Excalidraw path:

- **Mermaid to Excalidraw bridge.** Excalidraw ships a built-in "Mermaid to Excalidraw" importer (also the [`@excalidraw/mermaid-to-excalidraw`](https://github.com/excalidraw/mermaid-to-excalidraw) library). Paste the generated Mermaid to get editable shapes. It handles flowcharts and sequence diagrams well; complex graphs may need manual cleanup after import.
- **VS Code editing.** The [Excalidraw editor extension](https://marketplace.visualstudio.com/items?itemName=pomdtr.excalidraw-editor) (`pomdtr.excalidraw-editor`) opens and edits `.excalidraw`, `.excalidraw.svg`, and `.excalidraw.png` files directly in the editor, keeping diagrams in-repo.
- **Icon libraries.** [libraries.excalidraw.com](https://libraries.excalidraw.com) provides community icon sets (Kubernetes, AWS, GCP, Azure, networking) — directly useful for the infrastructure (#4) and AWS-equivalent (#5) diagrams.
- **Scene-embedded exports.** Saving as `.excalidraw.svg` or `.excalidraw.png` embeds the editable scene inside the exported asset, so a single file is both the source and the rendered image.
- **Consistent style.** Excalidraw defaults to a hand-drawn (Virgil) look. For a formal thesis, set a lower "Sloppiness" and the "Normal" font, and keep one consistent style across all figures.
- **Generated companions.** Each `NN-*.mmd` has a committed `NN-*.excalidraw` produced by the official converter (`@excalidraw/mermaid-to-excalidraw` + `convertToExcalidrawElements`, run headless through Chrome). Open these directly to finish layout. The converter approximates unsupported shapes (hexagons, cylinders) as rectangles and drops `classDef` colors, so restyle inside Excalidraw. The starting layout is Mermaid's auto-layout — this is where the pixel-level tweaks (equal box sizes, equal arrow lengths) that Mermaid cannot guarantee are finished by hand.

### What Claude can and cannot do

- Claude Code can generate all Mermaid sources, and raw `.excalidraw` JSON scaffolds on request.
- Claude Code cannot draw on the Excalidraw canvas — there is no first-party Excalidraw tool. The supported path is Mermaid (authored by Claude) imported into Excalidraw for manual polish.
- Third-party "Excalidraw MCP" servers exist but are unvetted; they are not relied on for this work.

## Export for LaTeX

The thesis loads figures via `\includegraphics` from `thesis/img/` (for example `img/argocd.png`).

- Prefer **vector** output: export SVG, then convert to PDF for `pdflatex` (`inkscape --export-type=pdf diagram.svg`, or `rsvg-convert -f pdf`). The LaTeX `svg` package can also embed SVG directly (requires Inkscape and `--shell-escape`).
- PNG at 2x scale is an acceptable raster fallback.
- Authored Mermaid/Excalidraw sources live under `docs/diagrams/`; the exported asset is copied into `thesis/img/` for inclusion.

## Diagram catalogue

Two families: architecture (a context-to-detail zoom) and process/flow.
Every entry has a Mermaid source under `docs/diagrams/`; all render cleanly.

### Architecture family

| # | Diagram | Thesis section | Shows |
| --- | --- | --- | --- |
| 1 | System overview (context) | `3_1` | User to Traefik Ingress to frontend (Vue 3 / nginx) to backend services to PostgreSQL — the whole system at a glance. |
| 2 | Detailed apps | `3_1` / `3_2` | `users`, `tasks` (REST) plus `task-archiver` consuming Apache Pulsar, frontend, and PostgreSQL — the synchronous and asynchronous paths together. |
| 3 | Detailed observability | `3_8` | Quarkus to OTLP to OTel Collector (logs to Loki, traces to Tempo) plus Prometheus scrape, all into Grafana. |
| 4 | Detailed infrastructure | `3_6` / `3_7` | Namespaces (`bsc-devops`, `observability`, `argocd`, `kube-system`), k3d nodes, Traefik, ArgoCD controller, Sealed Secrets controller, persistent volumes, RBAC / ServiceAccounts. |
| 5 | AWS cloud-equivalent (proposed) | `3_7` | Local-to-managed mapping: k3d to EKS, Traefik to ALB, PostgreSQL to RDS, in-cluster LGTM to managed Grafana / AMP, GHCR to ECR, Sealed Secrets to Secrets Manager. Illustrates the cloud-agnostic claim; marked as proposed, not implemented. |

### Process and flow family

| # | Diagram | Thesis section | Shows |
| --- | --- | --- | --- |
| 6 | CI pipeline and Shift-Left Security | `3_3` | GitHub Actions: Gradle native build to JUnit to Docker image to Trivy scan (gate) to Cosign signing to registry push. |
| 7 | GitOps delivery flow | `3_6` | ArgoCD pull-based reconciliation of two flat sibling `Application` resources from the GHCR OCI chart (see App-of-Apps note). |
| 8 | Sealed Secrets flow and bootstrap order | `3_6` | `kubeseal` asymmetric encryption to Git to in-cluster controller decryption; applied before ArgoCD during bootstrap. |
| 9 | Trace, log, and metric correlation | `3_8` | A single request's `traceId` flowing into MDC / JSON logs and spans; Grafana cross-links Tempo, Loki, and Prometheus. |
| 10 | End-to-end capstone sequence | `3_9` / `99` | commit to CI to chart publish to ArgoCD reconcile to rolling update to telemetry in Grafana. |

## Decisions and notes

- **Format:** Mermaid as the canonical source (2026-06-16). Excalidraw is an optional polish layer.
- **Dropped from the original list:** the DevOps lifecycle loop (already covered by `thesis/img/devops-cycle.png`) and the Sigstore keyless-signing detail (too low-level).
- **Architecture split:** the single architecture diagram was expanded into a five-part context-to-detail zoom (#1–#5).
- **Diagram #7 (GitOps) — decision (a), draw as-is.** The repository has **no App-of-Apps pattern**. `gitops/` holds two independent sibling ArgoCD `Application` manifests: `application.yaml` (the `bsc-devops-apps` chart) and `observability.yaml` (the observability chart). App-of-Apps appears only as an aspiration in `thesis/plan-draft.md`. The diagram depicts the real two-app topology; the thesis can note when App-of-Apps becomes worthwhile (roughly five or more Applications).
- **Verified `apps/` inventory:** `frontend`, `users`, `tasks`, `task-archiver`, plus an Apache Pulsar broker and PostgreSQL.
- **Verified observability charts:** Grafana, Loki, Prometheus, Tempo, plus the OTel Collector.

## Source files

Each diagram is a standalone Mermaid source under `docs/diagrams/`:

- `01-system-overview.mmd`
- `02-detailed-apps.mmd`
- `03-observability.mmd`
- `04-infrastructure.mmd`
- `05-aws-equivalent.mmd`
- `06-ci-pipeline.mmd`
- `07-gitops-flow.mmd`
- `08-sealed-secrets.mmd`
- `09-correlation.mmd`
- `10-capstone-sequence.mmd`

All ten parse and render with `@mermaid-js/mermaid-cli`.
Rendering needs a Chromium browser; on a machine with Chrome or Edge installed, point the CLI at it (forward slashes avoid escaping on Windows):

```bash
cat > pptr.json <<'JSON'
{"executablePath":"C:/Program Files/Google/Chrome/Application/chrome.exe","args":["--no-sandbox"]}
JSON
npx -y @mermaid-js/mermaid-cli -i docs/diagrams/01-system-overview.mmd -o out.svg -p pptr.json
```

## Status

All ten Mermaid sources are generated, verified, and exported to `thesis/img/` as high-resolution PNG (`NN-*.png`, scale 3, white background) to match the existing `\includegraphics{img/...}` convention.
Re-render a single diagram to PNG with the [render command](#source-files), swapping the output for `-o thesis/img/01-system-overview.png -b white -s 3`.

Not yet committed.
The diagrams are not yet referenced from the `.tex` files — wiring them into `figure` environments with Polish captions is the remaining step.
Excalidraw polish (or switching to vector PDF/SVG export) stays optional.
