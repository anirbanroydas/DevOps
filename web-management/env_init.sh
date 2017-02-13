#!/bin/bash

source $ENV_INIT_SCRIPT_PATH/.env
echo "Environment : $ENVIRONMENT"

source $ENV_PATH/$ENVIRONMENT/cluster-node-names
source $ENV_PATH/$ENVIRONMENT/.env

if [ "$ENVIRONMENT" == "dev" ]; then
	echo "Dev Provisioning Tool : $DEV_PROVISIONING_TOOL_DRIVER"
		
	source $ENV_PATH/$ENVIRONMENT/$DEV_PROVISIONING_TOOL_DRIVER/.env
else
	echo "Cloud Provider : $CLOUD_PROVIDER"
	echo "Provisioning Tool : $PROVISIONING_TOOL"

	source $ENV_PATH/$ENVIRONMENT/$CLOUD_PROVIDER/$PROVISIONING_TOOL/.env
fi



echo "Cluser Size: $CLUSTER_SIZE"
echo "Manager Nodes : $MANAGER_COUNT"
echo "WORKER Nodes : $WORKER_COUNT"



export CLUSTER_MANAGER_HOSTNAME=${CLUSTER_MANAGER_NAMES[0]}-01

# print the cluster swarm manager hostname
echo "Swarm Cluster Manager Hostname : $CLUSTER_MANAGER_HOSTNAME"



function start_service() {

	local SERVICE_NAME=""

	# start the service in the swarm manager node
	echo "Starting $1 service..."

	if [ "$2" == "swarm-viewer-ui" ]; then
		SERVICE_NAME=$SWARM_VIEWER_UI_SERVICE_NAME
		SERVICE_IMAGE=$SWARM_VIEWER_UI_SERVICE_IMAGE
		SERVICE_IMAGE_TAG=$SWARM_VIEWER_UI_SERVICE_IMAGE_TAG
	else
		if [ "$2" == "portainer" ]; then
			SERVICE_NAME=$DOCKER_MANAGEMENT_WEB_UI_SERVICE_NAME
			SERVICE_IMAGE=$DOCKER_MANAGEMENT_WEB_UI_SERVICE_IMAGE
			SERVICE_IMAGE_TAG=$DOCKER_MANAGEMENT_WEB_UI_SERVICE_IMAGE_TAG

		else
			if [ "$2" == "weave-scope" ]; then
				SERVICE_NAME=$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME
				SERVICE_IMAGE=$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_IMAGE
				SERVICE_IMAGE_TAG=$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_IMAGE_TAG
			fi
		fi
	fi

	# first check if the service is already running or not
	# if running then move on, otherwise create the service
	echo "[$SERVICE_NAME] - First, checking if service is already running or not..."
	docker-machine ssh "$CLUSTER_MANAGER_HOSTNAME" <<- EOSSH
		docker service ps -f "desired-state=running" "$SERVICE_NAME" > /dev/null 2>&1
		if [ $? -eq 0 ];
		then
			# service is already running
			echo "$1 service already running, moving forward"
		else
			# check if service is shutdown or not, if shutdown rm the service and then start
			# otherwise it may give duplicate service error (possible)
			echo "$1 service is not running, check if the service is shutdown"
			docker service ps -f "desired-state=shutdown" "$SERVICE_NAME" > /dev/null 2>&1
			if [ $? -eq 0 ];
			then
				# service is shutdown and hence exists, remove servcie and recreate
				echo "$1 service already present in shutdown state, removing and creating new one..."
				echo "Removing the service now.."
				docker service rm "$SERVICE_NAME" 2>&1
				echo "$1 service removed successfully, creating new one..."
				
			else
				# service is not present
				echo "$1 service is not  present or not in shutdown state, hence creating new one.."
			fi
			# now start the service
			# echo "first pulling image"
			# echo "image name : $SERVICE_IMAGE"
			# echo "image tag : $SERVICE_IMAGE_TAG"
			# docker pull "$SERVICE_IMAGE:$SERVICE_IMAGE_TAG"
			# echo "image pulled successfully"
			echo "creating service from image"
			echo "service creation command:"
			echo "$3"
			# execuite the command
			eval $(3)

		fi

		echo "$1 service started successfully"

	EOSSH

}

