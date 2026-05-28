# Changelog

## [1.1.0](https://github.com/mwas-inz/bsc-devops/compare/tasks-v1.0.0...tasks-v1.1.0) (2026-05-28)


### Features

* add multi-stage Dockerfiles for all services (Java 25, Gradle 9) ([f97e0d0](https://github.com/mwas-inz/bsc-devops/commit/f97e0d00007025a6e6e9492b29cd738ecbfc1471))
* fix: update Quarkus images and CI build ([5f9c7d2](https://github.com/mwas-inz/bsc-devops/commit/5f9c7d2d134935f38a1d73910b77bb39eebe31fc))
* **tasks:** add UserEvent record and KnownUser local replica entity ([c414236](https://github.com/mwas-inz/bsc-devops/commit/c4142362c538adb6f20baabf6f3b6847b26bb487))
* **tasks:** consume user-events from Pulsar to maintain KnownUser replica ([6fe5202](https://github.com/mwas-inz/bsc-devops/commit/6fe520200c02a8b15baab173ab59abd77a8acd6d))
* **tasks:** migrate tasks service to monorepo ([59e2954](https://github.com/mwas-inz/bsc-devops/commit/59e2954506775f541b00904d08384be610771612))
* **tasks:** replace synchronous UsersRestClient call with local KnownUser lookup ([6d1b0d6](https://github.com/mwas-inz/bsc-devops/commit/6d1b0d6614a40cfa3f79023930c3c8fccd7f7cb6))
* update Dockerfiles to use Alpine images for improved security ([cca3ad0](https://github.com/mwas-inz/bsc-devops/commit/cca3ad07d6e46607fd0aaf2c72791e1593719e61))


### Bug Fixes

* delete manual Dockerfile as Quarkus is already managing images ([4c44936](https://github.com/mwas-inz/bsc-devops/commit/4c44936f8c59680880e693aca6696ebb929f280a))
* deprecated gradle syntax ([86f5fda](https://github.com/mwas-inz/bsc-devops/commit/86f5fda79e8a822d13b31ed526be474cf13d3388))
* final code review fixes - k8s labels, IT test inheritance, build.gradle cleanup ([4848fc7](https://github.com/mwas-inz/bsc-devops/commit/4848fc74b97a6f7b009b8733630f37eabc829687))
* **tasks:** add @PathParam annotations, fix rest-client URL port, disable plain jar ([c45ee60](https://github.com/mwas-inz/bsc-devops/commit/c45ee60f1f81bfb5c1655415df9fb874b04e3181))
* update builder image to jdk-25 for Quarkus builds ([0f8cf55](https://github.com/mwas-inz/bsc-devops/commit/0f8cf558acb346bab01f7a8bf98e69ea6ffcb016))
* update user and group creation commands in Dockerfiles ([0dee6a8](https://github.com/mwas-inz/bsc-devops/commit/0dee6a847e539de766af5490c852d5379381df3a))
* use STRING schema with Jackson for Pulsar user-events channel ([a0610f1](https://github.com/mwas-inz/bsc-devops/commit/a0610f116c4169db0034f5d75e8ec32cf14c1cb0))
