# Changelog

## [1.2.1](https://github.com/mwas-inz/bsc-devops/compare/frontend-v1.2.0...frontend-v1.2.1) (2026-05-31)


### Bug Fixes

* **frontend:** mount emptyDir volumes for nginx cache and run directories ([ac07322](https://github.com/mwas-inz/bsc-devops/commit/ac07322576e5bd81f6d6178a9eaef85af70868a7))
* **tasks,task-archiver,frontend:** unify service port to 8080 across configurations ([81e644c](https://github.com/mwas-inz/bsc-devops/commit/81e644c54fdc2c2c62daa71dfa124fe14135775e))

## [1.2.0](https://github.com/mwas-inz/bsc-devops/compare/frontend-v1.1.0...frontend-v1.2.0) (2026-05-31)


### Features

* **infrastructure:** add Kubernetes manifests for local Minikube deployment ([42b3857](https://github.com/mwas-inz/bsc-devops/commit/42b38574b44a333c3ddbaf02e3ad3bbaa43c5925))


### Bug Fixes

* **infrastructure:** use IMAGE_TAG placeholder and resolve from git SHA at deploy time ([2e41352](https://github.com/mwas-inz/bsc-devops/commit/2e41352d254d32d817aad9a3ec18fe6b6f51e299))

## [1.1.0](https://github.com/mwas-inz/bsc-devops/compare/frontend-v1.0.0...frontend-v1.1.0) (2026-05-31)


### Features

* **frontend:** add AppHeader with health polling ([10be4ab](https://github.com/mwas-inz/bsc-devops/commit/10be4ab08b48fd1b5c1a623e08639517354ffd94))
* **frontend:** add avatar gradient utility ([e6b76c5](https://github.com/mwas-inz/bsc-devops/commit/e6b76c5a91860aa57ade70d674d1d705ebf62791))
* **frontend:** add Kubernetes Deployment, Service, and Ingress ([d530440](https://github.com/mwas-inz/bsc-devops/commit/d530440c0f3f567d74851a88908e8bb1ecc91431))
* **frontend:** add multi-stage Dockerfile and Nginx config ([2acdca4](https://github.com/mwas-inz/bsc-devops/commit/2acdca48b948d8f83a20d7356437a47f68f29143))
* **frontend:** add shared API types ([a0f7bba](https://github.com/mwas-inz/bsc-devops/commit/a0f7bbaecbcc4d85a397a63b7868f338a7757be2))
* **frontend:** add TaskCard component ([666d834](https://github.com/mwas-inz/bsc-devops/commit/666d8341077dc59046e94924ab52ea9ee5435dce))
* **frontend:** add TaskPanel component ([2a42611](https://github.com/mwas-inz/bsc-devops/commit/2a4261119ff49960489968b43cf84b96effb1252))
* **frontend:** add tasks API layer with tests ([0125e4e](https://github.com/mwas-inz/bsc-devops/commit/0125e4e344fff185db428525ad14ff9e17320d72))
* **frontend:** add UserCard component ([879039a](https://github.com/mwas-inz/bsc-devops/commit/879039a525b21cea0efccb4b527392209b1b8484))
* **frontend:** add UserPanel component ([c4c1b92](https://github.com/mwas-inz/bsc-devops/commit/c4c1b9250799bed795b74bceaca85bddbe5c7a47))
* **frontend:** add users API layer with tests ([9e8d03a](https://github.com/mwas-inz/bsc-devops/commit/9e8d03a662166e482f962d97541a96530ecac134))
* **frontend:** scaffold Vue 3 + Vite project ([3087314](https://github.com/mwas-inz/bsc-devops/commit/3087314c7978024dbd32e5930a734b79bdc5dc08))
* **frontend:** wire App.vue with full state management ([5f7b5b5](https://github.com/mwas-inz/bsc-devops/commit/5f7b5b5ce33ae7e1c7667e197a6f64e9166d2327))


### Bug Fixes

* **frontend:** guard avatar utility against empty name ([fe9374f](https://github.com/mwas-inz/bsc-devops/commit/fe9374f075e84d75c622820f961ec6008e70e7ca))
* **frontend:** update node, nginx and CVE in Dockerfile ([c40b7b6](https://github.com/mwas-inz/bsc-devops/commit/c40b7b614b01f86f099f8a549bcdc07ae0baf00a))
