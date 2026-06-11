# Thesis

LaTeX source for the engineering thesis: *Nowoczesne praktyki DevOps w chmurowym cyklu życia
oprogramowania* (Modern DevOps practices in cloud-native software development lifecycle).

## Compilation

Requires MiKTeX and Strawberry Perl (for `latexmk`).

```sh
bash scripts/thesis/compile-thesis.sh   # compile → thesis/main.pdf
bash scripts/thesis/cleanup-thesis.sh   # remove auxiliary files
```

The `thesis` GitHub Actions workflow compiles the PDF on every push to `thesis/**`.

## Chapter Structure

| File | Content |
| --- | --- |
| `tex/1-wstep.tex` | Introduction — motivation and thesis scope |
| `tex/2-teoria.tex` | Theory — DevOps and cloud-native concepts |
| `tex/3_0-projekt.tex` | Project overview — system goals and constraints |
| `tex/3_1-architektura.tex` | Architecture — microservices, messaging, frontend |
| `tex/3_2_1-plan.tex` | Planning — Jira, Conventional Commits, ADR workflow |
| `tex/3_2_2-code.tex` | Code — Quarkus, Gradle, OpenAPI |
| `tex/3_3-build.tex` | Build — Docker, GitHub Actions CI, Trivy, Cosign |
| `tex/3_4-test.tex` | Test — unit and integration tests |
| `tex/3_5-release.tex` | Release — semantic versioning, release-please |
| `tex/3_6-deploy.tex` | Deploy — Helm, ArgoCD, GitOps, Sealed Secrets |
| `tex/3_7-operate.tex` | Operate — k3d local cluster, RBAC, namespaces |
| `tex/3_8-monitor.tex` | Monitor — OpenTelemetry, LGTM observability stack |
| `tex/3_9-podsumowanie.tex` | Chapter summary |
| `tex/99-podsumowanie.tex` | Conclusion |
| `tex/zalaczniki.tex` | Appendices — ADR index, tech card index |
| `bibliografia.bib` | BibTeX references |
