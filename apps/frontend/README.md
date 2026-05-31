# frontend

Vue 3 + Vite + TypeScript split-panel dashboard for demoing the `users` and `tasks` microservices.

## Development

Requires both backend services running locally.

```sh
npm install
npm run dev        # http://localhost:5173
```

The Vite dev server proxies API calls to the backends:

| Frontend path    | Backend                    |
| ---------------- | -------------------------- |
| `/api/users/*`   | `users` service on `:8080` |
| `/api/tasks/*`   | `tasks` service on `:8081` |
| `/health/users`  | `users` `/q/health`        |
| `/health/tasks`  | `tasks` `/q/health`        |

## Build

```sh
npm run build      # outputs to dist/
```

## Test

```sh
npm test           # Vitest, 14 unit tests
```

## Container

Multi-stage Docker build — Node builds the Vite bundle, Nginx serves it and proxies API calls to the upstream Kubernetes services.

```sh
docker build -t frontend:local .
```

In production, Nginx upstream names `users` and `tasks` must resolve to the Kubernetes Services of the same name.

## Kubernetes

`kubernetes.yml` contains a Deployment, Service, and Ingress.
Image: `ghcr.io/mwas-inz/frontend`.
