# Stage 1: Build — full JDK + Gradle, compiles the monorepo subproject
FROM gradle:9-jdk25-alpine AS build
WORKDIR /workspace

# Copy dependency declarations first for better layer caching
COPY settings.gradle gradle.properties ./
COPY gradle/ gradle/

# Copy shared library and the target service
COPY libs/ libs/
COPY apps/tasks/ apps/tasks/

RUN gradle :apps:tasks:build -x test --no-daemon --build-cache

# Stage 2: Runtime — minimal JRE, no build tooling
FROM eclipse-temurin:25-jre-alpine
RUN addgroup -g 1001 quarkus && adduser -u 1001 -G quarkus -D quarkus
WORKDIR /deployments

COPY --chown=1001:1001 --from=build /workspace/apps/tasks/build/quarkus-app/lib/ lib/
COPY --chown=1001:1001 --from=build /workspace/apps/tasks/build/quarkus-app/*.jar ./
COPY --chown=1001:1001 --from=build /workspace/apps/tasks/build/quarkus-app/app/ app/
COPY --chown=1001:1001 --from=build /workspace/apps/tasks/build/quarkus-app/quarkus/ quarkus/

EXPOSE 8080
USER 1001
ENTRYPOINT ["java", \
  "-Dquarkus.http.host=0.0.0.0", \
  "-Djava.util.logging.manager=org.jboss.logmanager.LogManager", \
  "-jar", "/deployments/quarkus-run.jar"]
