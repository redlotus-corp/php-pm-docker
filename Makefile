VERSION?=dev-master
HTTP_VERSION?=dev-master
TAG?=latest
PREFIX?=phppm

# example:
# $ make VERSION=dev-master TAG=latest nginx
# $ make PREFIX=redlotuscorp TAG=latest VERSION=2.0 HTTP_VERSION=2.0.2 nginx
# $ make PREFIX=redlotuscorp TAG=latest push-all

# notes:
# dev-master + dev-master incompatible in composer requirements

nginx:
	docker build -t ${PREFIX}/ppm-nginx:${TAG} -f build/Dockerfile-nginx build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
	docker tag ${PREFIX}/ppm-nginx:${TAG} ${PREFIX}/ppm-nginx:latest

ppm:
	docker build -t ${PREFIX}/ppm:${TAG} -f build/Dockerfile-ppm build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
	docker tag ${PREFIX}/ppm:${TAG} ${PREFIX}/ppm:latest

standalone:
	docker build -t ${PREFIX}/ppm-standalone:${TAG} -f build/Dockerfile-standalone build/ --build-arg version=${VERSION} --build-arg http_version=${HTTP_VERSION}
	docker tag ${PREFIX}/ppm-standalone:${TAG} ${PREFIX}/ppm-standalone:latest

push-all:
	docker push ${PREFIX}/ppm-nginx:${TAG}
	docker push ${PREFIX}/ppm-standalone:${TAG}
	docker push ${PREFIX}/ppm:${TAG}
