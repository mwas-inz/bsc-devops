# Changelog

## [1.1.0](https://github.com/mwas-inz/bsc-devops/compare/task-archiver-v1.0.0...task-archiver-v1.1.0) (2026-05-28)


### Features

* add multi-stage Dockerfiles for all services (Java 25, Gradle 9) ([f97e0d0](https://github.com/mwas-inz/bsc-devops/commit/f97e0d00007025a6e6e9492b29cd738ecbfc1471))
* fix: update Quarkus images and CI build ([5f9c7d2](https://github.com/mwas-inz/bsc-devops/commit/5f9c7d2d134935f38a1d73910b77bb39eebe31fc))
* **task-archiver:** migrate task-archiver service to monorepo ([8f85f25](https://github.com/mwas-inz/bsc-devops/commit/8f85f2530a5be76f0dc71278d7cab06da6f862ad))
* update Dockerfiles to use Alpine images for improved security ([cca3ad0](https://github.com/mwas-inz/bsc-devops/commit/cca3ad07d6e46607fd0aaf2c72791e1593719e61))


### Bug Fixes

* delete manual Dockerfile as Quarkus is already managing images ([4c44936](https://github.com/mwas-inz/bsc-devops/commit/4c44936f8c59680880e693aca6696ebb929f280a))
* deprecated gradle syntax ([86f5fda](https://github.com/mwas-inz/bsc-devops/commit/86f5fda79e8a822d13b31ed526be474cf13d3388))
* final code review fixes - k8s labels, IT test inheritance, build.gradle cleanup ([4848fc7](https://github.com/mwas-inz/bsc-devops/commit/4848fc74b97a6f7b009b8733630f37eabc829687))
* **task-archiver:** remove unused REST deps, dedup app name property ([540e17f](https://github.com/mwas-inz/bsc-devops/commit/540e17f4adf5120e48a4e37ce4f255ac8389bfb4))
* update builder image to jdk-25 for Quarkus builds ([0f8cf55](https://github.com/mwas-inz/bsc-devops/commit/0f8cf558acb346bab01f7a8bf98e69ea6ffcb016))
* update user and group creation commands in Dockerfiles ([0dee6a8](https://github.com/mwas-inz/bsc-devops/commit/0dee6a847e539de766af5490c852d5379381df3a))
