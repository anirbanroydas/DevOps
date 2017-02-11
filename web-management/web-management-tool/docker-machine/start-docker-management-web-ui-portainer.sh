#!/bin/bash

source .env

source $ENV_INIT_SCRIPT_PATH/env_init.sh

SERVICE_COMMAND="docker service create \
	--name="$DOCKER_MANAGEMENT_WEB_UI_SERVICE_NAME" \
	--publish="$PORTAINER_PORT":9000 \
	--constraint=node.role==manager \
	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	$DOCKER_MANAGEMENT_WEB_UI_SERVICE_IMAGE:$DOCKER_MANAGEMENT_WEB_UI_SERVICE_IMAGE_TAG \
	-H unix:///var/run/docker.sock"


start_service "Docker Management Web UI Portainer"  portainer  "$SERVICE_COMMAND"

# --mount=type=bind,src=/Users/Roy/Documents/Github/sources/public/DevOps/web-management/dev/portainer-data,dst=/data \   	