# Stage 1: Build — full JDK + Gradle, compiles the monorepo subproject
FROM gradle:9-jdk25 AS build
WORKDIR /workspace

# Copy dependency declarations first for better layer caching
COPY settings.gradle gradle.properties ./
COPY gradle/ gradle/

# Copy shared library and the target service
COPY libs/ libs/
COPY apps/users/ apps/users/

RUN gradle :apps:users:build -x test --no-daemon --build-cache

# Stage 2: Runtime — minimal JRE, no build tooling
FROM eclipse-temurin:25-jre
RUN groupadd --gid 1001 quarkus && useradd --uid 1001 --gid quarkus quarkus
WORKDIR /deployments

COPY --chown=1001:1001 --from=build /workspace/apps/users/build/quarkus-app/lib/ lib/
COPY --chown=1001:1001 --from=build /workspace/apps/users/build/quarkus-app/*.jar ./
COPY --chown=1001:1001 --from=build /workspace/apps/users/build/quarkus-app/app/ app/
COPY --chown=1001:1001 --from=build /workspace/apps/users/build/quarkus-app/quarkus/ quarkus/

EXPOSE 8080
USER 1001
ENTRYPOINT ["java", \
  "-Dquarkus.http.host=0.0.0.0", \
  "-Djava.util.logging.manager=org.jboss.logmanager.LogManager", \
  "-jar", "/deployments/quarkus-run.jar"]
