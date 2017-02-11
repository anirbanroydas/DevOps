#!/bin/bash

source .env

source $ENV_INIT_SCRIPT_PATH/env_init.sh

# Swarm Viewer Manomarks/visualizer
echo "Starting Swarm Viewer Ui.."

SERVICE_COMMAND="docker service create \
	--name="$SWARM_VIEWER_UI_SERVICE_NAME" \
	--publish="$VISUALIZER_PORT":8080/tcp \
	--constraint=node.role==manager \
	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	$SWARM_VIEWER_UI_SERVICE_IMAGE:$SWARM_VIEWER_UI_SERVICE_IMAGE_TAG"


(
	start_service "Swarm Viewer Ui"  swarm-viewer  "$SERVICE_COMMAND"
) &


# Portainer
echo "Starting Docker Management Web UI Portainer Ui.."

SERVICE_COMMAND="docker service create \
	--name="$DOCKER_MANAGEMENT_WEB_UI_SERVICE_NAME" \
	--publish="$PORTAINER_PORT":9000 \
	--constraint=node.role==manager \
	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	$DOCKER_MANAGEMENT_WEB_UI_SERVICE_IMAGE:$DOCKER_MANAGEMENT_WEB_UI_SERVICE_IMAGE_TAG \
	-H unix:///var/run/docker.sock"


(
	start_service "Docker Management Web UI Portainer"  portainer  "$SERVICE_COMMAND"
) &

# Weave Scope
echo "Starting Microservices Viewer Web Ui Weave Scope.."

SERVICE_COMMAND="docker service create \
	--name="$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME" \
	--mode=global \
	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_IMAGE:$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_IMAGE_TAG \
	scope launch"


(
	start_service "Microservices Viewer Web UI weave-scope"  weave-scope  "$SERVICE_COMMAND"
) &



echo "wating for services to be created..."
wait
echo "Services cretaed successfully"

