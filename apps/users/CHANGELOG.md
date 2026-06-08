# Changelog

## [1.1.2](https://github.com/mwas-inz/bsc-devops/compare/users-v1.1.1...users-v1.1.2) (2026-06-08)


### Bug Fixes

* **config:** replace deprecated hibernate-orm schema generation property ([08fd403](https://github.com/mwas-inz/bsc-devops/commit/08fd40311577b2c6130ea5e91e28ec8678584364))
* **config:** replace deprecated hibernate-orm schema generation property ([dbbcf94](https://github.com/mwas-inz/bsc-devops/commit/dbbcf94e49763672088227c4466d1ee0801d033d))

## [1.1.1](https://github.com/mwas-inz/bsc-devops/compare/users-v1.1.0...users-v1.1.1) (2026-05-31)


### Bug Fixes

* **users,tasks:** register UserEvent for native image reflection ([4d12bab](https://github.com/mwas-inz/bsc-devops/commit/4d12babd37936dc872c299efc6bcf61829664c8d))

## [1.1.0](https://github.com/mwas-inz/bsc-devops/compare/users-v1.0.0...users-v1.1.0) (2026-05-28)


### Features

* add multi-stage Dockerfiles for all services (Java 25, Gradle 9) ([f97e0d0](https://github.com/mwas-inz/bsc-devops/commit/f97e0d00007025a6e6e9492b29cd738ecbfc1471))
* fix: update Quarkus images and CI build ([5f9c7d2](https://github.com/mwas-inz/bsc-devops/commit/5f9c7d2d134935f38a1d73910b77bb39eebe31fc))
* update Dockerfiles to use Alpine images for improved security ([cca3ad0](https://github.com/mwas-inz/bsc-devops/commit/cca3ad07d6e46607fd0aaf2c72791e1593719e61))
* **users:** add Pulsar dependency and UserEvent record ([b0160ce](https://github.com/mwas-inz/bsc-devops/commit/b0160ce306c5bdf7782fdb0aa62aad3c4036d4bd))
* **users:** migrate users service to monorepo ([e691317](https://github.com/mwas-inz/bsc-devops/commit/e6913177a5a8c7a959792edb24a19917394a79c4))
* **users:** publish UserEvent to Pulsar on create and delete ([eddfcc4](https://github.com/mwas-inz/bsc-devops/commit/eddfcc4ee43bc0199eb79b8a35a1b3eedc97fa3d))


### Bug Fixes

* delete manual Dockerfile as Quarkus is already managing images ([4c44936](https://github.com/mwas-inz/bsc-devops/commit/4c44936f8c59680880e693aca6696ebb929f280a))
* deprecated gradle syntax ([86f5fda](https://github.com/mwas-inz/bsc-devops/commit/86f5fda79e8a822d13b31ed526be474cf13d3388))
* final code review fixes - k8s labels, IT test inheritance, build.gradle cleanup ([4848fc7](https://github.com/mwas-inz/bsc-devops/commit/4848fc74b97a6f7b009b8733630f37eabc829687))
* update builder image to jdk-25 for Quarkus builds ([0f8cf55](https://github.com/mwas-inz/bsc-devops/commit/0f8cf558acb346bab01f7a8bf98e69ea6ffcb016))
* update user and group creation commands in Dockerfiles ([0dee6a8](https://github.com/mwas-inz/bsc-devops/commit/0dee6a847e539de766af5490c852d5379381df3a))
* use STRING schema with Jackson for Pulsar user-events channel ([a0610f1](https://github.com/mwas-inz/bsc-devops/commit/a0610f116c4169db0034f5d75e8ec32cf14c1cb0))
* **users:** add circe-checksum and cpu-affinity for Pulsar native image build ([b56d7da](https://github.com/mwas-inz/bsc-devops/commit/b56d7da93e308ed11b89df591131ddd34fae00f3))
* **users:** code review fixes - BOM ordering, app name, credentials, devservices scope ([b86270e](https://github.com/mwas-inz/bsc-devops/commit/b86270e22cb766fc69c3715b41ea88eabd5d1fc3))
