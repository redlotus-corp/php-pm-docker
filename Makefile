VERSION?=2.0.1
HTTP_VERSION?=2.0.2
TAG?=latest
TAG_MESSAGE?="Updated versions"
PREFIX?=redlotuscorp
COMPOSER?=1.9

# Determine this makefile's path.
# Be sure to place this BEFORE `include` directives, if any.
THIS_FILE := $(lastword $(MAKEFILE_LIST))

# example:
# $ make VERSION=dev-master HTTP_VERSION=dev-master TAG=1.0.0 nginx
# $ make PREFIX=redlotuscorp VERSION=2.0 HTTP_VERSION=2.0.2 TAG=1.0.0 nginx
# $ make PREFIX=redlotuscorp VERSION=2.0 HTTP_VERSION=2.0.2 TAG=1.0.0 build-all
# $ make PREFIX=redlotuscorp TAG=1.0.0 push-all
# $ make PREFIX=redlotuscorp TAG=1.0.0 TAG_MESSAGE="PHP 7.3.9; Composer 1.9; PHP-PM 2.0; PHP-PM-HTTP 2.0.2" deliver
# $ make TAG=latest VERSION=dev-master HTTP_VERSION=2.0.2 nginx-test

# notes:
# dev-master + dev-master incompatible in composer requirements

.PHONY: nginx
nginx:
	docker build -t ${PREFIX}/ppm-nginx:${TAG} -f build/Dockerfile.nginx build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION} --build-arg composer=${COMPOSER}
	docker tag ${PREFIX}/ppm-nginx:${TAG} ${PREFIX}/ppm-nginx:latest

.PHONY: ppm
ppm:
	docker build -t ${PREFIX}/ppm:${TAG} -f build/Dockerfile.ppm build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION} --build-arg composer=${COMPOSER}
	docker tag ${PREFIX}/ppm:${TAG} ${PREFIX}/ppm:latest

.PHONY: standalone
standalone:
	docker build -t ${PREFIX}/ppm-standalone:${TAG} -f build/Dockerfile.standalone build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION} --build-arg composer=${COMPOSER}
	docker tag ${PREFIX}/ppm-standalone:${TAG} ${PREFIX}/ppm-standalone:latest

.PHONY: build-all
build-all:
	@$(MAKE) -f $(THIS_FILE) PREFIX=${PREFIX} TAG=${TAG} VERSION=${VERSION} HTTP_VERSION=${HTTP_VERSION} nginx
	@$(MAKE) -f $(THIS_FILE) PREFIX=${PREFIX} TAG=${TAG} VERSION=${VERSION} HTTP_VERSION=${HTTP_VERSION} ppm
	@$(MAKE) -f $(THIS_FILE) PREFIX=${PREFIX} TAG=${TAG} VERSION=${VERSION} HTTP_VERSION=${HTTP_VERSION} standalone

.PHONY: push-all
push-all:
	docker push ${PREFIX}/ppm-nginx:${TAG}
	docker push ${PREFIX}/ppm-standalone:${TAG}
	docker push ${PREFIX}/ppm:${TAG}

.PHONY: deliver
deliver:
	git commit -am "Updated verions"
	git tag -a v${TAG} -m "${TAG_MESSAGE}" && git push origin v${TAG} || true
	@$(MAKE) -f $(THIS_FILE) PREFIX=${PREFIX} TAG=${TAG} build-all
	@$(MAKE) -f $(THIS_FILE) PREFIX=${PREFIX} TAG=${TAG} push-all

.PHONY: nginx-test
nginx-test:
	DOCKER_BUILDKIT=1 docker build --ssh github=${HOME}/.ssh/id_rsa -t ${PREFIX}/ppm-nginx-test:latest -f build/Dockerfile.nginx-test build/ --build-arg composer=${COMPOSER}
