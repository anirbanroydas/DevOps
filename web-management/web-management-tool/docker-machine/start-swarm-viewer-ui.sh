#!/bin/bash

source .env

source $ENV_INIT_SCRIPT_PATH/env_init.sh

SERVICE_COMMAND="docker service create \
	--name="$SWARM_VIEWER_UI_SERVICE_NAME" \
	--publish="$VISUALIZER_PORT":8080/tcp \
	--constraint=node.role==manager \
	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	$SWARM_VIEWER_UI_SERVICE_IMAGE:$SWARM_VIEWER_UI_SERVICE_IMAGE_TAG"


start_service "Swarm Viewer Ui"  swarm-viewer  "$SERVICE_COMMAND"

