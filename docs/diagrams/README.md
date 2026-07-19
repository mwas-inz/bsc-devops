# Diagrams

Architecture and flow diagrams for the thesis, authored as Mermaid sources under `docs/diagrams/<phase>/` and rendered to PNG figures under `thesis/img/diagrams/<phase>/` (same basename).

## Why Mermaid

- **Diagrams as code** — plain-text `.mmd` sources are versioned, diffable, and reviewable in Git, consistent with the thesis *Everything as Code* argument.
- **Zero-friction rendering** — GitHub and IDEs render Mermaid inline; one CLI command reproduces every figure, with no binary editor state.
- Chosen over PlantUML/D2 (no inline GitHub rendering at decision time) and over drawing tools (not reproducible from text).

## Configuration

- Every source sets `config: theme: neo` via frontmatter (clean white/black base suited to print). The CLI `-t` flag rejects `neo`, so the theme **must** be set via frontmatter.
- **Print legibility contract:** every diagram must yield an effective font size of **≥ 7 pt** when scaled to its `\includegraphics` width (`\textwidth` ≈ 15.4 cm ≈ 437 pt). Effective pt = `fontPx / naturalSvgWidthPx × 437 × widthFactor`. PNG resolution (`-s 3`) does **not** affect print size — only the font-to-layout-width ratio does. Check the natural width in the rendered SVG's `viewBox` before wiring a figure.
- **Shared config pattern** (flowcharts): `themeVariables: fontSize: 22px` plus `flowchart: nodeSpacing/rankSpacing/padding/diagramPadding` tuned per diagram and `wrappingWidth: 600` (disables ragged auto-wrap at 200 px — line breaks are set manually with `<br/>`, aiming at ≤ ~26 chars per line).
- **Sequence diagrams** ignore `sequence.*FontSize` and `themeVariables.fontSize`; the working knob is top-level `config: fontSize: 22`. Margins come from `sequence:` keys (`actorMargin`, `diagramMarginX`, ...). `autonumber` badges are hardcoded at 12 px (illegible in print) — not used.
- **Titles are not rendered into the images**: each figure's description lives in the LaTeX `\caption`; the former frontmatter `title` is kept as a `%%` comment. This avoids duplication and reclaims height.
- **Labels are Polish** (the thesis figure language); product names, identifiers, and config keys stay as-is.
- A shared semantic `classDef` palette keeps the set consistent: blue = services/steps, orange = artifacts/data, green = cluster/live, purple = Git/GitOps, pink = security, dashed grey = notes and hypothetical alternatives.
- Mermaid quirks to remember:
  - Parentheses in **edge** labels must be quoted (`|"...(x)"|`).
  - An edge into a subgraph-internal node overrides that subgraph's `direction` — route the edge to the subgraph itself and order internals with invisible `~~~` links.
  - **Snake (boustrophedon) layouts** — used to fold wide chains into two rows — are built as `flowchart TB` with two invisible subgraphs (`fill:none,stroke:none`) of `direction LR` / `direction RL`; the cross-subgraph connector always renders as a centered boundary stub (dagre limitation), which is accepted.
  - Subgraph titles must be **single-line** (a `<br/>` second line is clipped by the first node) and no wider than the subgraph body (otherwise it overlaps neighbours).
  - Disconnected components render **in reverse declaration order** (last-declared leftmost).
  - Multi-line labels overflow stadium `([...])` shapes — use rounded rects `(...)` for multi-line nodes.
  - Reversed feedback edges (`A <-.- B`) are normalized to `B → A` for layout too, so they cannot force rank placement — but declaring the cycle this way still lets dagre break it at the intended edge.

Render a diagram to its thesis PNG (needs a local Chromium/Chrome):

```bash
cat > pptr.json <<'JSON'
{"executablePath":"C:/Program Files/Google/Chrome/Application/chrome.exe","args":["--no-sandbox"]}
JSON
npx -y @mermaid-js/mermaid-cli -i docs/diagrams/<phase>/<name>.mmd \
  -o thesis/img/diagrams/<phase>/<name>.png -p pptr.json -b white -s 3
```

The thesis includes figures via `\includegraphics{img/diagrams/<phase>/<name>.png}`.

## Structure

Files are named `<chapter>-<NN>-<slug>` and grouped into phase folders numbered in the thesis (DevOps lifecycle) order.
Diagrams dropped from the thesis set are deleted outright; their history stays in Git.

## Diagram ToC

**Wired** = included in the thesis as a `figure` with the given label; all 21 are wired — the set is complete.

### 01-teoria (chapter 2)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `teoria-01-twelve-factor` | `fig:twelve-factor-map` | All twelve factors mapped to their concrete implementation in the project; factor XII marked as a conscious deviation. |
| `teoria-02-shared-responsibility` | `fig:shared-responsibility` | Who manages which layer — local k3d vs IaaS vs managed Kubernetes vs SaaS. |
| `teoria-03-portability-layers` | `fig:portability-layers` | Invariant artifacts (app → OCI → Helm → K8s API) above a portability boundary; only the runtime below it is swapped. |

### 02-architektura (3_1)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `architektura-01-system-overview` | `fig:system-overview` | Single overview: the synchronous path (Traefik routing, JDBC) and the event cascade through Pulsar topics (`user-events` → `delete-tasks`), annotated with the event-fed `KnownUser` read model — no synchronous call between services. |

### 03-plan (3_2_1)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `plan-01-flow-traceability` | `fig:traceability` | The requirement ID's journey: Jira → branch → commit footer → PR → artifacts → ArgoCD, with automatic Jira back-links. |

### 04-build (3_3)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `build-01-ci-pipeline` | `fig:ci-pipeline` | The CI chain with shift-left security: tests → native image → Trivy gate → push → Cosign signing. |
| `build-02-flow-ci-governance` | `fig:ci-governance` | Same workflow, two behaviors: PR runs validate only, `main` runs publish and sign; branch protection gates the merge. Pair of `build-01`. |
| `build-03-flow-native-build` | `fig:native-build` | JIT vs AOT: Mandrel-container compilation traded for millisecond startup and a minimal JVM-free image. |

### 05-test (3_4)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `test-01-flow-devservices-test` | `fig:devservices-test` | Dev Services sequence: missing DB URL → Testcontainers PostgreSQL → RestAssured tests with `@TestTransaction` rollback. |

### 06-release (3_5)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `release-01-flow-chart-release` | `fig:chart-release` | Two workflows coupled by an immutable `chart-apps-<version>` tag; OCI chart push to GHCR; ArgoCD pins the version. |

### 07-deploy (3_6)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `deploy-01-gitops-flow` | `fig:gitops-flow` | The pull-model reconciliation loop; the one-time bootstrap apply is the only inbound edge. |
| `deploy-02-flow-selfheal` | `fig:selfheal` | Drift experiment: a manual `kubectl scale` is detected and reverted by `selfHeal`. |
| `deploy-03-sealed-secrets` | `fig:sealed-secrets` | `kubeseal` asymmetric encryption and the bootstrap order (secrets before ArgoCD). |

### 08-operate (3_7)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `operate-01-infrastructure` | `fig:infrastructure` | Four namespaces, four roles: platform, delivery, workload, observation. |
| `operate-02-aws-equivalent` | `fig:aws-equivalent` | Local components mapped to managed AWS equivalents (proposal, consciously not implemented). |

### 09-monitor (3_8)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `monitor-01-observability` | `fig:observability-flow` | Three signals, two transport patterns: OTLP push for logs and traces, Prometheus pull for metrics. |
| `monitor-02-correlation` | `fig:correlation` | One `traceId` written to logs and traces; the operator's pivot journey in Grafana. |
| `monitor-03-vendor-neutral-seam` | `fig:vendor-neutral-seam` | OTel Collector as the vendor-neutral seam: a backend swap is a config change, not a code change. |

### 10-podsumowanie (3_9 / 99)

| Diagram | Wired | Shows |
| --- | --- | --- |
| `podsumowanie-01-capstone-sequence` | `fig:capstone-sequence` | The full cycle of one change: commit → CI → publish → reconcile → rolling update → telemetry. |
| `podsumowanie-02-value-stream` | `fig:value-stream` | One change's journey with the automation boundary made countable: exactly two manual steps (commit, release decision) — everything else executes itself; observation feeds the next change. |
| `podsumowanie-03-control-loop` | `fig:control-loop` | The SDLC as a control system with two nested feedback loops: the machine loop (ArgoCD selfHeal, seconds) and the human loop (observation → conscious correction of the desired state). |

## Notes

- The GitOps diagrams draw the repository as it is: two independent sibling ArgoCD `Application` manifests, **no App-of-Apps pattern** (worthwhile only at roughly five or more Applications).
- `build-01` and `build-02` are a deliberate pair (one workflow on two axes) and are wired adjacently with cross-referencing captions.
- The authoring spec for the theory/mechanism wave (node labels, verified repo facts, render order) lives in [`specs/theory-and-mechanism-diagrams.md`](specs/theory-and-mechanism-diagrams.md), written under pre-rename slugs.
