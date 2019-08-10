VERSION?=dev-master
HTTP_VERSION?=dev-master
TAG?=latest
PREFIX?=phppm

# example:
# $ make VERSION=dev-master TAG=latest nginx
# $ make PREFIX=redlotus-phppm VERSION=2.0 HTTP_VERSION=2.0.2 nginx

# notes:
# dev-master + dev-master incompatible in composer requirements

nginx:
	docker build -t ${PREFIX}/nginx:${TAG} -f build/Dockerfile-nginx build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
	docker tag ${PREFIX}/nginx:${TAG} ${PREFIX}/nginx:latest

ppm:
	docker build -t ${PREFIX}/ppm:${TAG} -f build/Dockerfile-ppm build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
	docker tag ${PREFIX}/ppm:${TAG} ${PREFIX}/ppm:latest

standalone:
	docker build -t ${PREFIX}/standalone:${TAG} -f build/Dockerfile-standalone build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
	docker tag ${PREFIX}/standalone:${TAG} ${PREFIX}/standalone:latest

push-all:
	docker push ${PREFIX}/nginx:${TAG}
	docker push ${PREFIX}/standalone:${TAG}
	docker push ${PREFIX}/ppm:${TAG}
