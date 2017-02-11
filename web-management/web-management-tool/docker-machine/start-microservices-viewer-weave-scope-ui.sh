#!/bin/bash

source .env

source $ENV_INIT_SCRIPT_PATH/env_init.sh

SERVICE_COMMAND="docker service create \
	--name="$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME" \
	--mode=global \
	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_IMAGE:$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_IMAGE_TAG \
	scope launch"


start_service "Microservices Viewer Web UI weave-scope"  weave-scope  "$SERVICE_COMMAND"


