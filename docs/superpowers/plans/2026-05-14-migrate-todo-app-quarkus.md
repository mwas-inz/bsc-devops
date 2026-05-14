# Migrate todo-app-quarkus Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Copy the 3 Quarkus services from `../todo-app-quarkus` into `bsc-devops/apps/`, rename all packages from `pl.mwas` → `pl.edu.pw.eiti.mwas`, and wire them under a unified Gradle multi-project build.

**Architecture:** Root `settings.gradle` uses `include` for each app subproject. Shared Gradle wrapper and `gradle.properties` at repo root. Each service keeps its own `build.gradle`, source, tests, resources, and Dockerfiles. No cross-service source dependencies — entities are duplicated per service by design.

**Tech Stack:** Quarkus 3.12.2, Gradle 8.x, Java 21, Lombok (tasks + task-archiver only), Apache Pulsar (tasks + task-archiver), PostgreSQL, OpenTelemetry/LGTM, Docker

---

### Task 1: Root Gradle infrastructure

**Files:**
- Create: `settings.gradle`
- Create: `gradle.properties`
- Create: `build.gradle`
- Copy: `gradlew`, `gradlew.bat`, `gradle/wrapper/gradle-wrapper.jar`, `gradle/wrapper/gradle-wrapper.properties`

- [ ] **Step 1: Copy Gradle wrapper from source repo**

Run from `bsc-devops/` root:

```bash
cp C:/Users/mateusz.was/coding/todo-app-quarkus/gradlew ./gradlew
cp C:/Users/mateusz.was/coding/todo-app-quarkus/gradlew.bat ./gradlew.bat
mkdir -p gradle/wrapper
cp C:/Users/mateusz.was/coding/todo-app-quarkus/gradle/wrapper/gradle-wrapper.jar ./gradle/wrapper/gradle-wrapper.jar
cp C:/Users/mateusz.was/coding/todo-app-quarkus/gradle/wrapper/gradle-wrapper.properties ./gradle/wrapper/gradle-wrapper.properties
```

- [ ] **Step 2: Create `gradle.properties`**

```properties
quarkusPlatformGroupId=io.quarkus.platform
quarkusPlatformArtifactId=quarkus-bom
quarkusPlatformVersion=3.12.2
```

- [ ] **Step 3: Create `settings.gradle`**

```groovy
pluginManagement {
    repositories {
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id 'io.quarkus' version "${quarkusPlatformVersion}"
        id 'io.freefair.lombok' version '8.6'
    }
}

rootProject.name = 'bsc-devops'

include(':apps:tasks')
include(':apps:users')
include(':apps:task-archiver')
```

- [ ] **Step 4: Create `build.gradle` (root)**

```groovy
// Root build — each service is configured in its own build.gradle
```

- [ ] **Step 5: Commit**

```bash
git add settings.gradle gradle.properties build.gradle gradlew gradlew.bat gradle/
git commit -m "chore: add root Gradle multi-project build infrastructure"
```

---

### Task 2: Migrate `users` service

**Files:**
- Create: `apps/users/build.gradle`
- Create: `apps/users/src/main/java/pl/edu/pw/eiti/mwas/users/User.java`
- Create: `apps/users/src/main/java/pl/edu/pw/eiti/mwas/users/UsersResource.java`
- Create: `apps/users/src/main/resources/application.properties`
- Create: `apps/users/src/main/resources/application-prod.properties`
- Copy: `apps/users/src/main/docker/Dockerfile.{jvm,native,legacy-jar,native-micro}`
- Create: `apps/users/src/test/java/pl/edu/pw/eiti/mwas/users/UserResourceTest.java`
- Create: `apps/users/src/native-test/java/pl/edu/pw/eiti/mwas/users/UserResourceIT.java`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p apps/users/src/main/java/pl/edu/pw/eiti/mwas/users
mkdir -p apps/users/src/main/resources
mkdir -p apps/users/src/main/docker
mkdir -p apps/users/src/test/java/pl/edu/pw/eiti/mwas/users
mkdir -p apps/users/src/native-test/java/pl/edu/pw/eiti/mwas/users
```

- [ ] **Step 2: Create `apps/users/build.gradle`**

```groovy
plugins {
    id 'java'
    id 'io.quarkus'
}

repositories {
    mavenCentral()
    mavenLocal()
}

dependencies {
    implementation 'io.quarkus:quarkus-kubernetes'
    implementation 'io.quarkus:quarkus-micrometer-registry-prometheus'
    implementation 'io.quarkus:quarkus-config-yaml'
    implementation 'io.quarkus:quarkus-jdbc-postgresql'
    implementation enforcedPlatform("${quarkusPlatformGroupId}:${quarkusPlatformArtifactId}:${quarkusPlatformVersion}")
    implementation 'io.quarkus:quarkus-hibernate-orm-panache'
    implementation 'io.quarkus:quarkus-hibernate-orm-rest-data-panache'
    implementation 'io.quarkus:quarkus-rest'
    implementation 'io.quarkus:quarkus-smallrye-openapi'
    implementation 'io.quarkus:quarkus-rest-jackson'
    implementation 'io.quarkus:quarkus-opentelemetry'
    implementation 'io.quarkus:quarkus-arc'
    testImplementation 'io.quarkus:quarkus-junit5'
    testImplementation 'io.rest-assured:rest-assured'

    implementation "io.quarkus:quarkus-observability-devservices-lgtm"
    implementation "io.opentelemetry.instrumentation:opentelemetry-jdbc"
}

group 'pl.edu.pw.eiti.mwas'
version '1.0.0'

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

test {
    systemProperty "java.util.logging.manager", "org.jboss.logmanager.LogManager"
}
compileJava {
    options.encoding = 'UTF-8'
    options.compilerArgs << '-parameters'
}
compileTestJava {
    options.encoding = 'UTF-8'
}

jar {
    enabled = false
}

quarkusBuild {
    nativeArgs {
        containerBuild = true
        builderImage = "quay.io/quarkus/ubi-quarkus-mandrel-builder-image:jdk-21"
    }
}
```

- [ ] **Step 3: Create `apps/users/src/main/java/pl/edu/pw/eiti/mwas/users/User.java`**

```java
package pl.edu.pw.eiti.mwas.users;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User extends PanacheEntity {

    @Column(nullable = false)
    public String name;

    @Column(nullable = false)
    public String email;
}
```

- [ ] **Step 4: Create `apps/users/src/main/java/pl/edu/pw/eiti/mwas/users/UsersResource.java`**

```java
package pl.edu.pw.eiti.mwas.users;

import io.quarkus.hibernate.orm.rest.data.panache.PanacheEntityResource;

public interface UsersResource extends PanacheEntityResource<User, Long> {
}
```

- [ ] **Step 5: Create `apps/users/src/main/resources/application.properties`**

```properties
quarkus.http.port=8080

quarkus.datasource.db-kind=postgresql
quarkus.hibernate-orm.database.generation=update

quarkus.container-image.group=mateuszwas
quarkus.container-image.name=users
quarkus.container-image.tag=1.0.0

quarkus.kubernetes.idempotent=true
quarkus.kubernetes.part-of=todo-app-quarkus
quarkus.kubernetes.name=users
quarkus.kubernetes.version=1.0.0
```

- [ ] **Step 6: Create `apps/users/src/main/resources/application-prod.properties`**

```properties
quarkus.application.name=users
quarkus.http.port=8080

quarkus.datasource.db-kind=postgresql
quarkus.datasource.jdbc.url=jdbc:postgresql://postgres:5432/todo
quarkus.datasource.jdbc.telemetry=true
quarkus.datasource.username=todo
quarkus.datasource.password=todo

quarkus.hibernate-orm.database.generation=update

quarkus.native.enabled=true
quarkus.native.container-build=true
quarkus.native.container-runtime=docker

quarkus.package.jar.enabled=false

quarkus.otel.exporter.otlp.traces.endpoint=http://jaeger:4317
quarkus.micrometer.export.otlp.url=http://jaeger:4318/v1/metrics
quarkus.log.console.format=%d{HH:mm:ss} %-5p traceId=%X{traceId}, parentId=%X{parentId}, spanId=%X{spanId}, sampled=%X{sampled} [%c{2.}] (%t) %s%e%n

quarkus.container-image.group=mateuszwas
quarkus.container-image.name=users
quarkus.container-image.tag=1.0.0

quarkus.kubernetes.idempotent=true
quarkus.kubernetes.part-of=todo-app-quarkus
quarkus.kubernetes.name=users
quarkus.kubernetes.version=1.0.0
```

- [ ] **Step 7: Copy Dockerfiles verbatim**

```bash
cp C:/Users/mateusz.was/coding/todo-app-quarkus/users/src/main/docker/Dockerfile.jvm         apps/users/src/main/docker/Dockerfile.jvm
cp C:/Users/mateusz.was/coding/todo-app-quarkus/users/src/main/docker/Dockerfile.native       apps/users/src/main/docker/Dockerfile.native
cp C:/Users/mateusz.was/coding/todo-app-quarkus/users/src/main/docker/Dockerfile.legacy-jar   apps/users/src/main/docker/Dockerfile.legacy-jar
cp C:/Users/mateusz.was/coding/todo-app-quarkus/users/src/main/docker/Dockerfile.native-micro apps/users/src/main/docker/Dockerfile.native-micro
```

- [ ] **Step 8: Create `apps/users/src/test/java/pl/edu/pw/eiti/mwas/users/UserResourceTest.java`**

```java
package pl.edu.pw.eiti.mwas.users;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

@QuarkusTest
class UserResourceTest {
    @Test
    void testHelloEndpoint() {
        given()
          .when().get("/users")
          .then()
             .statusCode(200);
    }
}
```

- [ ] **Step 9: Create `apps/users/src/native-test/java/pl/edu/pw/eiti/mwas/users/UserResourceIT.java`**

```java
package pl.edu.pw.eiti.mwas.users;

import io.quarkus.test.junit.QuarkusIntegrationTest;

@QuarkusIntegrationTest
class UserResourceIT extends UserResourceTest {
    // Execute the same tests but in packaged mode.
}
```

- [ ] **Step 10: Verify users compiles and tests pass**

```bash
./gradlew :apps:users:build
```

Expected: `BUILD SUCCESSFUL`. Quarkus DevServices spins up a PostgreSQL container automatically for the test.

- [ ] **Step 11: Commit**

```bash
git add apps/users/
git commit -m "feat(users): migrate users service to monorepo"
```

---

### Task 3: Migrate `tasks` service

**Files:**
- Create: `apps/tasks/build.gradle`
- Create: `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks/Task.java`
- Create: `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks/TaskRepository.java`
- Create: `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks/TaskResource.java`
- Create: `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks/TaskStatus.java`
- Create: `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/users/User.java`
- Create: `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/users/UsersRestClient.java`
- Create: `apps/tasks/src/main/resources/application.properties`
- Create: `apps/tasks/src/main/resources/application-prod.properties`
- Copy: `apps/tasks/src/main/docker/Dockerfile.{jvm,native,legacy-jar,native-micro}`
- Create: `apps/tasks/src/test/java/pl/edu/pw/eiti/mwas/tasks/TaskResourceTest.java`
- Create: `apps/tasks/src/native-test/java/pl/edu/pw/eiti/mwas/tasks/TaskResourceIT.java`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks
mkdir -p apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/users
mkdir -p apps/tasks/src/main/resources
mkdir -p apps/tasks/src/main/docker
mkdir -p apps/tasks/src/test/java/pl/edu/pw/eiti/mwas/tasks
mkdir -p apps/tasks/src/native-test/java/pl/edu/pw/eiti/mwas/tasks
```

- [ ] **Step 2: Create `apps/tasks/build.gradle`**

```groovy
plugins {
    id 'java'
    id 'io.quarkus'
    id 'io.freefair.lombok'
}

repositories {
    mavenCentral()
    mavenLocal()
}

dependencies {
    implementation 'io.quarkus:quarkus-kubernetes'
    implementation 'io.quarkus:quarkus-micrometer-registry-prometheus'
    implementation 'io.quarkus:quarkus-messaging-pulsar'
    implementation enforcedPlatform("${quarkusPlatformGroupId}:${quarkusPlatformArtifactId}:${quarkusPlatformVersion}")
    implementation 'io.quarkus:quarkus-hibernate-orm-rest-data-panache'
    implementation 'io.quarkus:quarkus-rest'
    implementation 'io.quarkus:quarkus-rest-client-jackson'
    implementation 'io.quarkus:quarkus-rest-client'
    implementation 'io.quarkus:quarkus-smallrye-openapi'
    implementation 'io.quarkus:quarkus-rest-jackson'
    implementation 'io.quarkus:quarkus-opentelemetry'
    implementation 'io.quarkus:quarkus-hibernate-orm-panache'
    implementation 'io.quarkus:quarkus-smallrye-health'
    implementation 'io.quarkus:quarkus-jdbc-postgresql'
    implementation 'io.quarkus:quarkus-arc'
    implementation 'io.quarkus:quarkus-hibernate-orm'
    testImplementation 'io.quarkus:quarkus-junit5'
    testImplementation 'io.rest-assured:rest-assured'

    // transitive dependency fix for Pulsar
    // https://github.com/smallrye/smallrye-reactive-messaging/discussions/2567#discussioncomment-9042159
    implementation("org.apache.bookkeeper:circe-checksum:4.16.1") {
        artifact { type = "jar" }
    }
    implementation("org.apache.bookkeeper:cpu-affinity:4.16.1") {
        artifact { type = "jar" }
    }
    implementation "io.quarkus:quarkus-observability-devservices-lgtm"
    implementation "io.opentelemetry.instrumentation:opentelemetry-jdbc"
}

group 'pl.edu.pw.eiti.mwas'
version '1.0.0'

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

test {
    systemProperty "java.util.logging.manager", "org.jboss.logmanager.LogManager"
}
compileJava {
    options.encoding = 'UTF-8'
    options.compilerArgs << '-parameters'
}
compileTestJava {
    options.encoding = 'UTF-8'
}

quarkusBuild {
    nativeArgs {
        containerBuild = true
        builderImage = "quay.io/quarkus/ubi-quarkus-mandrel-builder-image:jdk-21"
    }
}
```

- [ ] **Step 3: Create `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks/TaskStatus.java`**

```java
package pl.edu.pw.eiti.mwas.tasks;

public enum TaskStatus {
    created,
    done
}
```

- [ ] **Step 4: Create `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks/Task.java`**

```java
package pl.edu.pw.eiti.mwas.tasks;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.RequiredArgsConstructor;
import lombok.ToString;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@ToString
@Builder
@RequiredArgsConstructor
@AllArgsConstructor
@Entity
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    public Long userId;

    public String title;
    public String content;

    @Enumerated(EnumType.STRING)
    public TaskStatus status;

    @CreationTimestamp
    public LocalDateTime createdAt;

    public LocalDateTime completedAt;
}
```

- [ ] **Step 5: Create `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks/TaskRepository.java`**

```java
package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

@ApplicationScoped
public class TaskRepository implements PanacheRepository<Task> {
    public List<Task> findTasksByUserId(Long userId) {
        return list("userId", userId);
    }
}
```

- [ ] **Step 6: Create `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/users/User.java`**

```java
package pl.edu.pw.eiti.mwas.users;

public class User {
    public Long id;
    public String name;
    public String email;
}
```

- [ ] **Step 7: Create `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/users/UsersRestClient.java`**

```java
package pl.edu.pw.eiti.mwas.users;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

@Path("/users")
@RegisterRestClient(configKey = "users")
public interface UsersRestClient {

    @GET
    @Path("/{userId}")
    public User getUserById(@PathParam("userId") Long userId);
}
```

- [ ] **Step 8: Create `apps/tasks/src/main/java/pl/edu/pw/eiti/mwas/tasks/TaskResource.java`**

```java
package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.logging.Log;
import jakarta.inject.Inject;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import pl.edu.pw.eiti.mwas.users.UsersRestClient;

import java.time.LocalDateTime;
import java.util.List;

@Path("/users/{userId}/tasks")
public class TaskResource {

    @Inject
    TaskRepository repository;

    @Channel("delete-tasks")
    Emitter<Long> deleteTasks;

    @RestClient
    UsersRestClient usersRestClient;

    @GET
    public List<Task> getTasks(Long userId) {
        checkIfUserIsPresent(userId);
        Log.info("Retrieving tasks for user " + userId);
        return repository.findTasksByUserId(userId);
    }

    @GET
    @Path("/{taskId}")
    public Task getTask(Long userId, Long taskId) {
        checkIfUserIsPresent(userId);
        Log.info("Retrieving task with id " + taskId);
        return repository.findById(taskId);
    }

    @POST
    @Transactional
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createTask(Long userId, Task task) {
        checkIfUserIsPresent(userId);
        Task aTask = Task.builder()
                .userId(userId)
                .title(task.title)
                .content(task.content)
                .status(TaskStatus.created)
                .build();
        repository.persist(aTask);

        Log.info("Saving task: " + aTask);

        return Response.ok(aTask).build();
    }

    @PATCH
    @Path("/{taskId}")
    @Transactional
    public Response changeStatus(Long userId, Long taskId, Task task) {
        checkIfUserIsPresent(userId);
        Task aTask = repository.findById(taskId);
        if (task.status == TaskStatus.done) {
            Log.info("Closing task: " + aTask);
            aTask.status = TaskStatus.done;
            aTask.completedAt = LocalDateTime.now();
        }

        return Response.ok(aTask).build();
    }

    @DELETE
    @Path("/{taskId}")
    public Response deleteTask(Long userId, Long taskId) {
        checkIfUserIsPresent(userId);
        Task aTask = repository.findById(taskId);
        Log.info("Scheduled deletion of task: " + aTask);

        deleteTasks.send(taskId);

        return Response.ok().build();
    }

    private void checkIfUserIsPresent(Long userId) {
        if (usersRestClient.getUserById(userId) == null) {
            throw new EntityNotFoundException("User with id " + userId + " not found");
        }
    }
}
```

- [ ] **Step 9: Create `apps/tasks/src/main/resources/application.properties`**

```properties
quarkus.http.port=8081

quarkus.datasource.db-kind=postgresql

quarkus.hibernate-orm.database.generation=update

# used with docker compose
quarkus.rest-client.users.url=http://localhost
quarkus.rest-client.users.scope=jakarta.inject.Singleton

quarkus.container-image.group=mateuszwas
quarkus.container-image.name=tasks
quarkus.container-image.tag=1.0.0

quarkus.kubernetes.idempotent=true
quarkus.kubernetes.part-of=todo-app-quarkus
quarkus.kubernetes.name=tasks
quarkus.kubernetes.version=1.0.0
```

- [ ] **Step 10: Create `apps/tasks/src/main/resources/application-prod.properties`**

```properties
quarkus.http.port=8080

quarkus.datasource.db-kind=postgresql
quarkus.datasource.jdbc.url=jdbc:postgresql://postgres:5432/todo
quarkus.datasource.username=todo
quarkus.datasource.password=todo

quarkus.hibernate-orm.database.generation=update

quarkus.native.enabled=true
quarkus.native.container-build=true
quarkus.native.container-runtime=docker

quarkus.package.jar.enabled=false

quarkus.rest-client.users.url=http://users:8080
quarkus.rest-client.users.scope=jakarta.inject.Singleton

mp.messaging.outgoing.delete-tasks.connector=smallrye-pulsar
mp.messaging.outgoing.delete-tasks.serviceUrl=pulsar://pulsar:6650

quarkus.micrometer.export.otlp.url=http://jaeger:4318/v1/metrics
quarkus.otel.exporter.otlp.traces.endpoint=http://jaeger:4317
quarkus.datasource.jdbc.telemetry=true
quarkus.application.name=tasks
quarkus.log.console.format=%d{HH:mm:ss} %-5p traceId=%X{traceId}, parentId=%X{parentId}, spanId=%X{spanId}, sampled=%X{sampled} [%c{2.}] (%t) %s%e%n

quarkus.container-image.group=mateuszwas
quarkus.container-image.name=tasks
quarkus.container-image.tag=1.0.0

quarkus.kubernetes.idempotent=true
quarkus.kubernetes.part-of=todo-app-quarkus
quarkus.kubernetes.name=tasks
quarkus.kubernetes.version=1.0.0
```

- [ ] **Step 11: Copy Dockerfiles verbatim**

```bash
cp C:/Users/mateusz.was/coding/todo-app-quarkus/tasks/src/main/docker/Dockerfile.jvm         apps/tasks/src/main/docker/Dockerfile.jvm
cp C:/Users/mateusz.was/coding/todo-app-quarkus/tasks/src/main/docker/Dockerfile.native       apps/tasks/src/main/docker/Dockerfile.native
cp C:/Users/mateusz.was/coding/todo-app-quarkus/tasks/src/main/docker/Dockerfile.legacy-jar   apps/tasks/src/main/docker/Dockerfile.legacy-jar
cp C:/Users/mateusz.was/coding/todo-app-quarkus/tasks/src/main/docker/Dockerfile.native-micro apps/tasks/src/main/docker/Dockerfile.native-micro
```

- [ ] **Step 12: Create `apps/tasks/src/test/java/pl/edu/pw/eiti/mwas/tasks/TaskResourceTest.java`**

```java
package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

@QuarkusTest
class TaskResourceTest {
    @Test
    void testCreateTask() {
        given()
                .when().get("/users/1/tasks/")
                .then()
                .statusCode(200);
    }
}
```

> **Note:** This test calls `GET /users/1/tasks/` which internally calls the `users` service REST client. The test will fail in isolation without a running `users` instance (connection refused on `http://localhost/users/1`). This is an existing limitation from the source repo — the test passes when all services are up via `docker-compose`.

- [ ] **Step 13: Create `apps/tasks/src/native-test/java/pl/edu/pw/eiti/mwas/tasks/TaskResourceIT.java`**

```java
package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.test.junit.QuarkusIntegrationTest;

@QuarkusIntegrationTest
class TaskResourceIT {
    // Execute the same tests but in packaged mode.
}
```

- [ ] **Step 14: Verify tasks compiles**

```bash
./gradlew :apps:tasks:compileJava :apps:tasks:compileTestJava
```

Expected: `BUILD SUCCESSFUL`. Note: `./gradlew :apps:tasks:build` will run tests that require the users service — skip tests for now with `:compileJava`.

- [ ] **Step 15: Commit**

```bash
git add apps/tasks/
git commit -m "feat(tasks): migrate tasks service to monorepo"
```

---

### Task 4: Migrate `task-archiver` service

**Files:**
- Create: `apps/task-archiver/build.gradle`
- Create: `apps/task-archiver/src/main/java/pl/edu/pw/eiti/mwas/taskarchiver/DeletionConsumer.java`
- Create: `apps/task-archiver/src/main/java/pl/edu/pw/eiti/mwas/tasks/Task.java`
- Create: `apps/task-archiver/src/main/java/pl/edu/pw/eiti/mwas/tasks/TaskRepository.java`
- Create: `apps/task-archiver/src/main/resources/application.properties`
- Create: `apps/task-archiver/src/main/resources/application-prod.properties`
- Copy: `apps/task-archiver/src/main/docker/Dockerfile.{jvm,native,legacy-jar,native-micro}`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p apps/task-archiver/src/main/java/pl/edu/pw/eiti/mwas/taskarchiver
mkdir -p apps/task-archiver/src/main/java/pl/edu/pw/eiti/mwas/tasks
mkdir -p apps/task-archiver/src/main/resources
mkdir -p apps/task-archiver/src/main/docker
mkdir -p apps/task-archiver/src/test/java
mkdir -p apps/task-archiver/src/native-test/java
```

- [ ] **Step 2: Create `apps/task-archiver/build.gradle`**

```groovy
plugins {
    id 'java'
    id 'io.quarkus'
    id 'io.freefair.lombok'
}

repositories {
    mavenCentral()
    mavenLocal()
}

dependencies {
    implementation 'io.quarkus:quarkus-kubernetes'
    implementation 'io.quarkus:quarkus-micrometer-registry-prometheus'
    implementation enforcedPlatform("${quarkusPlatformGroupId}:${quarkusPlatformArtifactId}:${quarkusPlatformVersion}")
    implementation 'io.quarkus:quarkus-jdbc-postgresql'
    implementation 'io.quarkus:quarkus-rest'
    implementation 'io.quarkus:quarkus-smallrye-openapi'
    implementation 'io.quarkus:quarkus-rest-jackson'
    implementation 'io.quarkus:quarkus-opentelemetry'
    implementation 'io.quarkus:quarkus-hibernate-orm-panache'
    implementation 'io.quarkus:quarkus-messaging-pulsar'
    implementation 'io.quarkus:quarkus-smallrye-health'
    implementation 'io.quarkus:quarkus-micrometer'
    implementation 'io.quarkus:quarkus-arc'
    implementation 'io.quarkus:quarkus-hibernate-orm'
    testImplementation 'io.quarkus:quarkus-junit5'
    testImplementation 'io.rest-assured:rest-assured'

    // transitive dependency fix for Pulsar
    // https://github.com/smallrye/smallrye-reactive-messaging/discussions/2567#discussioncomment-9042159
    implementation("org.apache.bookkeeper:circe-checksum:4.16.1") {
        artifact { type = "jar" }
    }
    implementation("org.apache.bookkeeper:cpu-affinity:4.16.1") {
        artifact { type = "jar" }
    }
    implementation "io.quarkus:quarkus-observability-devservices-lgtm"
    implementation "io.opentelemetry.instrumentation:opentelemetry-jdbc"
}

group 'pl.edu.pw.eiti.mwas'
version '1.0.0'

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

test {
    systemProperty "java.util.logging.manager", "org.jboss.logmanager.LogManager"
}
compileJava {
    options.encoding = 'UTF-8'
    options.compilerArgs << '-parameters'
}
compileTestJava {
    options.encoding = 'UTF-8'
}

quarkusBuild {
    nativeArgs {
        containerBuild = true
        builderImage = "quay.io/quarkus/ubi-quarkus-mandrel-builder-image:jdk-21"
    }
}
```

- [ ] **Step 3: Create `apps/task-archiver/src/main/java/pl/edu/pw/eiti/mwas/tasks/Task.java`**

```java
package pl.edu.pw.eiti.mwas.tasks;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    public Long userId;

    public String title;

    public String content;

    public String status;

    @CreationTimestamp
    public LocalDateTime createdAt;

    public LocalDateTime completedAt;
}
```

- [ ] **Step 4: Create `apps/task-archiver/src/main/java/pl/edu/pw/eiti/mwas/tasks/TaskRepository.java`**

```java
package pl.edu.pw.eiti.mwas.tasks;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class TaskRepository implements PanacheRepository<Task> {
}
```

- [ ] **Step 5: Create `apps/task-archiver/src/main/java/pl/edu/pw/eiti/mwas/taskarchiver/DeletionConsumer.java`**

```java
package pl.edu.pw.eiti.mwas.taskarchiver;

import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.eclipse.microprofile.reactive.messaging.Incoming;
import pl.edu.pw.eiti.mwas.tasks.TaskRepository;

@ApplicationScoped
public class DeletionConsumer {

    @Inject
    TaskRepository repository;

    @Incoming("delete-tasks")
    @Transactional
    public void deleteTask(Long taskId) {
        Log.info("Deleting task with taskId=" + taskId);
        repository.deleteById(taskId);
    }
}
```

- [ ] **Step 6: Create `apps/task-archiver/src/main/resources/application.properties`**

```properties
quarkus.http.port=8082

quarkus.datasource.db-kind=postgresql

quarkus.hibernate-orm.database.generation=update

quarkus.container-image.group=mateuszwas
quarkus.container-image.name=task-archiver
quarkus.container-image.tag=1.0.0

quarkus.kubernetes.idempotent=true
quarkus.kubernetes.part-of=todo-app-quarkus
quarkus.kubernetes.name=task-archiver
quarkus.kubernetes.version=1.0.0
```

- [ ] **Step 7: Create `apps/task-archiver/src/main/resources/application-prod.properties`**

```properties
quarkus.application.name=task-archiver
quarkus.http.port=8080

quarkus.datasource.db-kind=postgresql
quarkus.datasource.jdbc.url=jdbc:postgresql://postgres:5432/todo
quarkus.datasource.jdbc.telemetry=true
quarkus.datasource.username=todo
quarkus.datasource.password=todo

quarkus.hibernate-orm.database.generation=update

quarkus.native.enabled=true
quarkus.native.container-build=true
quarkus.native.container-runtime=docker

quarkus.package.jar.enabled=false

mp.messaging.incoming.delete-tasks.connector=smallrye-pulsar
mp.messaging.incoming.delete-tasks.serviceUrl=pulsar://pulsar:6650

quarkus.micrometer.export.otlp.url=http://jaeger:4318/v1/metrics
quarkus.otel.exporter.otlp.traces.endpoint=http://jaeger:4317
quarkus.log.console.format=%d{HH:mm:ss} %-5p traceId=%X{traceId}, parentId=%X{parentId}, spanId=%X{spanId}, sampled=%X{sampled} [%c{2.}] (%t) %s%e%n

quarkus.container-image.group=mateuszwas
quarkus.container-image.name=task-archiver
quarkus.container-image.tag=1.0.0

quarkus.kubernetes.idempotent=true
quarkus.kubernetes.part-of=todo-app-quarkus
quarkus.kubernetes.name=task-archiver
quarkus.kubernetes.version=1.0.0
```

- [ ] **Step 8: Copy Dockerfiles verbatim**

```bash
cp C:/Users/mateusz.was/coding/todo-app-quarkus/task-archiver/src/main/docker/Dockerfile.jvm         apps/task-archiver/src/main/docker/Dockerfile.jvm
cp C:/Users/mateusz.was/coding/todo-app-quarkus/task-archiver/src/main/docker/Dockerfile.native       apps/task-archiver/src/main/docker/Dockerfile.native
cp C:/Users/mateusz.was/coding/todo-app-quarkus/task-archiver/src/main/docker/Dockerfile.legacy-jar   apps/task-archiver/src/main/docker/Dockerfile.legacy-jar
cp C:/Users/mateusz.was/coding/todo-app-quarkus/task-archiver/src/main/docker/Dockerfile.native-micro apps/task-archiver/src/main/docker/Dockerfile.native-micro
```

- [ ] **Step 9: Verify task-archiver compiles**

```bash
./gradlew :apps:task-archiver:compileJava :apps:task-archiver:compileTestJava
```

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 10: Commit**

```bash
git add apps/task-archiver/
git commit -m "feat(task-archiver): migrate task-archiver service to monorepo"
```

---

### Task 5: Migrate infrastructure files

**Files:**
- Create: `infrastructure/docker-compose.yml`
- Create: `infrastructure/local/nginx/nginx.conf`
- Create: `infrastructure/local/postgres/postgres-configmap.yaml`
- Create: `infrastructure/local/postgres/postgres-pv.yaml`

- [ ] **Step 1: Create directories**

```bash
mkdir -p infrastructure/local/nginx
mkdir -p infrastructure/local/postgres
```

- [ ] **Step 2: Create `infrastructure/docker-compose.yml`**

```yaml
services:
  nginx:
    image: nginx:1.27-alpine-otel
    ports:
      - 80:80
    volumes:
      - ./local/nginx/nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - users
      - tasks
      - task-archiver
    restart: always

  postgres:
    image: postgres:16-alpine
    ports:
      - 5432:5432
    volumes:
      - todo_db:/var/lib/postgresql/data
    healthcheck:
      test: [ "CMD-SHELL", "pg_isready -U todo" ]
      interval: 1s
      timeout: 5s
      retries: 10
    environment:
      - POSTGRES_PASSWORD=todo
      - POSTGRES_USER=todo
      - POSTGRES_DB=todo

  pulsar:
    image: apachepulsar/pulsar:3.3.1
    ports:
      - 6650:6650
      - 8080:8080
    volumes:
      - pulsar_data:/pulsar/data
      - pulsar_conf:/pulsar/conf
    environment:
      - PULSAR_STANDALONE_USE_ZOOKEEPER=1
    healthcheck:
      test: [ "CMD-SHELL", "bin/pulsar-admin brokers healthcheck" ]
      interval: 30s
      timeout: 10s
      start_period: 30s
      retries: 5
    command: >
      bin/pulsar standalone

  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
      - "4317:4317"
      - "4318:4318"
      - "14250:14250"
    environment:
      - COLLECTOR_OTLP_ENABLED=true

  users:
    image: mateuszwas/users:1.0.0
    build:
      context: ../apps/users
      dockerfile: src/main/docker/Dockerfile.native
    ports:
      - 8080
    depends_on:
      postgres:
        condition: service_healthy

  tasks:
    image: mateuszwas/tasks:1.0.0
    build:
      context: ../apps/tasks
      dockerfile: src/main/docker/Dockerfile.native
    ports:
      - 8080
    depends_on:
      postgres:
        condition: service_healthy
      pulsar:
        condition: service_healthy

  task-archiver:
    image: mateuszwas/task-archiver:1.0.0
    build:
      context: ../apps/task-archiver
      dockerfile: src/main/docker/Dockerfile.native
    depends_on:
      postgres:
        condition: service_healthy
      pulsar:
        condition: service_healthy

volumes:
  todo_db:
  pulsar_data:
  pulsar_conf:
```

> **Note:** The `build.context` paths are updated from the source (`users` → `../apps/users`, etc.) to reflect the new monorepo layout.

- [ ] **Step 3: Create `infrastructure/local/nginx/nginx.conf`**

```nginx
server {
    listen 80;
    server_name localhost;

    # Route /users and /users/{userId} to users service
    location ~ ^/users(/[0-9]+)?$ {
        proxy_pass http://users:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Route /users/{userId}/tasks/{taskId} to tasks service
    location ~ ^/users/[0-9]+/tasks(/[0-9]+)?$ {
        proxy_pass http://tasks:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

- [ ] **Step 4: Create `infrastructure/local/postgres/postgres-configmap.yaml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-secret
  labels:
    app: postgres
data:
  POSTGRES_DB: todo
  POSTGRES_USER: todo
  POSTGRES_PASSWORD: todo
```

- [ ] **Step 5: Create `infrastructure/local/postgres/postgres-pv.yaml`**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-volume
  labels:
    type: local
    app: postgres
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /data/postgresql
```

- [ ] **Step 6: Commit**

```bash
git add infrastructure/
git commit -m "chore(infrastructure): add docker-compose and local infra manifests"
```

---

### Task 6: Remove stale artifacts and stubs

**Files:**
- Delete: `apps/task-api/` (build artifacts only, no source)
- Delete: `libs/task-domain/build/` (stale artifacts, no source)

- [ ] **Step 1: Remove `apps/task-api/`**

```bash
rm -rf apps/task-api
```

- [ ] **Step 2: Remove `libs/task-domain/build/`**

```bash
rm -rf libs/task-domain/build
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove stale task-api stub and task-domain build artifacts"
```

---

### Task 7: Verify full build

- [ ] **Step 1: Compile all services**

```bash
./gradlew :apps:users:compileJava :apps:tasks:compileJava :apps:task-archiver:compileJava
```

Expected: `BUILD SUCCESSFUL` — all three services compile without errors.

- [ ] **Step 2: Run users tests**

```bash
./gradlew :apps:users:test
```

Expected: `BUILD SUCCESSFUL`. Quarkus DevServices automatically provisions a PostgreSQL container via Testcontainers. Requires Docker to be running.

- [ ] **Step 3: Run task-archiver tests (no tests defined — just build check)**

```bash
./gradlew :apps:task-archiver:build -x test
```

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 4: Verify root build runs without error**

```bash
./gradlew build -x test
```

Expected: `BUILD SUCCESSFUL` for all three subprojects.

- [ ] **Step 5: Commit if any fixes were required**

```bash
git add -A
git commit -m "chore: verify and fix monorepo build"
```
