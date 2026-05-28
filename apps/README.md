# Apps

Sample microservices used as the subject of DevOps and cloud-native practices described in the thesis.
All services are Quarkus (Java 25) applications backed by PostgreSQL and communicating asynchronously via Apache Pulsar.

## Services

### users

REST API for user management. Port `8080`.

- `GET /users`, `GET /users/{id}` — list / fetch users
- `POST /users` — create a user; publishes a `user-events` message to Pulsar
- `DELETE /users/{id}` — delete a user; publishes a `user-events` message to Pulsar

### tasks

REST API for task management scoped to users. Port `8081`.

- `GET /users/{userId}/tasks`, `GET /users/{userId}/tasks/{taskId}` — list / fetch tasks
- `POST /users/{userId}/tasks` — create a task
- `PATCH /users/{userId}/tasks/{taskId}` — update task status (`created` → `done`)
- `DELETE /users/{userId}/tasks/{taskId}` — schedule task deletion; publishes a `delete-tasks` message to Pulsar

Consumes `user-events` from Pulsar to maintain a local `KnownUser` cache used for ownership validation.

### task-archiver

Background consumer service. Port `8082` (no public HTTP API).

Consumes `delete-tasks` messages from Pulsar and permanently removes tasks from the database.

## Common Stack

| Concern | Technology |
| --- | --- |
| Framework | Quarkus 3.x |
| Language | Java 25 |
| Persistence | PostgreSQL (Hibernate ORM Panache) |
| Messaging | Apache Pulsar (SmallRye Reactive Messaging) |
| Observability | OpenTelemetry (tracing), Micrometer/Prometheus (metrics) |
| Health | SmallRye Health (`/q/health`) |
| API docs | SmallRye OpenAPI (`/q/swagger-ui`) |
| Packaging | Container image (Docker), Kubernetes manifests generated at build |
| Native build | GraalVM Mandrel (container build) |

## Message Topics

| Topic | Publisher | Consumer |
| --- | --- | --- |
| `user-events` | `users` | `tasks` |
| `delete-tasks` | `tasks` | `task-archiver` |
