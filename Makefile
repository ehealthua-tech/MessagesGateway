.PHONY: all run build push

COMPOSE_PROJECT_NAME?=message_gateway_admin_web
COMPOSE_FILE?=docker/staging/docker-compose.yml
DOCKER_REGISTRY?=registry.skywell.software

DOCKER_IMAGE?=${DOCKER_REGISTRY}/${COMPOSE_PROJECT_NAME}/messages_gateway_api:latest
DOCKER_LOCAL_IMAGE?=docker.skywell/${COMPOSE_PROJECT_NAME}/messages_gateway_api:latest

COMPOSE_HTTP_TIMEOUT=86400

all:build run

run: create_networks
	docker-compose -p ${COMPOSE_PROJECT_NAME} -f ${COMPOSE_FILE} up -d

build:
	docker-compose -f ${COMPOSE_FILE} build

push:
	docker tag ${DOCKER_LOCAL_IMAGE} ${DOCKER_IMAGE}
	docker push ${DOCKER_IMAGE}
