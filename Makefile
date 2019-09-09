VERSION?=dev-master
HTTP_VERSION?=dev-master
TAG?=latest
PREFIX?=phppm

# Determine this makefile's path.
# Be sure to place this BEFORE `include` directives, if any.
THIS_FILE := $(lastword $(MAKEFILE_LIST))

# example:
# $ make VERSION=dev-master TAG=latest nginx
# $ make PREFIX=redlotuscorp TAG=latest VERSION=2.0 HTTP_VERSION=2.0.2 nginx
# $ make PREFIX=redlotuscorp TAG=latest VERSION=2.0 HTTP_VERSION=2.0.2 build-all
# $ make PREFIX=redlotuscorp TAG=latest push-all

# notes:
# dev-master + dev-master incompatible in composer requirements

.PHONY: nginx
nginx:
	docker build -t ${PREFIX}/ppm-nginx:${TAG} -f build/Dockerfile-nginx build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
	docker tag ${PREFIX}/ppm-nginx:${TAG} ${PREFIX}/ppm-nginx:latest

.PHONY: ppm
ppm:
	docker build -t ${PREFIX}/ppm:${TAG} -f build/Dockerfile-ppm build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
	docker tag ${PREFIX}/ppm:${TAG} ${PREFIX}/ppm:latest

.PHONY: standalone
standalone:
	docker build -t ${PREFIX}/ppm-standalone:${TAG} -f build/Dockerfile-standalone build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
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
