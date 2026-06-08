# Choose Vue 3 as Frontend Framework

* Status: accepted
* Date: 2026-05-28
* Decision-makers: mateusz.was
* Consulted:
* Informed:

## Context and Problem Statement

The bsc-devops project requires a frontend layer to complete the client-server architecture demonstration. The framework must be lightweight enough to serve as a thin UI layer over REST APIs, support TypeScript for type safety, and integrate well with modern build tooling (Vite). Since the frontend is a demonstration vehicle rather than the primary focus of the thesis, developer productivity and simplicity take precedence over enterprise-scale features.

## Decision Drivers

* **Developer Familiarity:** Vue 3's Composition API and template syntax offer a low barrier to entry compared to React's JSX model or Angular's decorator-heavy approach.
* **TypeScript Support:** First-class TypeScript support via `vue-tsc` and the Composition API, with no additional configuration overhead.
* **Vite Integration:** Vue 3 is the primary target of Vite, which provides near-instant HMR and optimized production builds — reducing CI build times.
* **Lightweight Scope:** The frontend is a supporting element of the thesis; a minimal, file-based single-page application (SPA) is sufficient.
* **Component Model:** Vue's single-file components (`.vue`) keep template, logic, and styles co-located, improving readability for academic presentation.

## Considered Options

* **Vue 3 (with Vite + TypeScript)**
* **React (with Vite + TypeScript)**
* **Angular**
* **Svelte / SvelteKit**

## Decision Outcome

Chosen option: **Vue 3 (with Vite + TypeScript)**, because it offers the best balance of developer productivity, TypeScript support, and Vite-native integration for a lightweight SPA that serves as a UI layer in a DevOps-focused thesis project.

### Consequences

* **Good:** Vite as the default build tool provides fast development iteration and small production bundles.
* **Good:** Single-file components (`.vue`) are self-documenting and easy to present in an academic context.
* **Good:** `vue-tsc` enables strict type checking as a CI step without additional tooling.
* **Bad:** Smaller ecosystem than React for enterprise UI component libraries.
* **Bad:** Less widespread adoption in enterprise contexts compared to Angular or React, which may limit direct industry applicability of the demonstrated patterns.

## Pros and Cons of the Options

### Vue 3 (with Vite + TypeScript)

* Good, because Vite is Vue's native build tool — zero-config setup.
* Good, because the Composition API aligns well with TypeScript's type inference.
* Bad, because the ecosystem of third-party UI libraries is smaller than React's.

### React (with Vite + TypeScript)

* Good, because it has the largest ecosystem and community support.
* Bad, because JSX syntax adds cognitive overhead and is less readable in academic listings.
* Bad, because React's state management patterns (hooks, context) introduce additional complexity for a thin UI layer.

### Angular

* Good, because it provides a complete, opinionated framework with built-in DI and routing.
* Bad, because it is significantly more complex to set up and overkill for a demonstration SPA.
* Bad, because the build toolchain (Angular CLI) is heavier than Vite.

### Svelte / SvelteKit

* Good, because it produces the smallest bundles with no virtual DOM overhead.
* Bad, because it has the smallest ecosystem and the author has no prior experience with it.

## More Information

* Vue 3 documentation: [https://vuejs.org/](https://vuejs.org/)
* Vite documentation: [https://vitejs.dev/](https://vitejs.dev/)
* Related: ADR-0003 (Java/JVM backend), ADR-0005 (Dockerfile containerization strategy)
