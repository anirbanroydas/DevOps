#!/bin/bash

source env_init.sh

# start the docker management portainer web ui service in the swarm manager node
echo "Starting Dccker Management Web Ui Portainer..."

# first check if the service is already running or not
# if running then move on, otherwise create the service
echo "First, checking if service is already running or not..."
docker service ps -f "desired-state=running" "$DOCKER_MANAGEMENT_WEB_UI_SERVICE_NAME" > /dev/null 2>&1
if [ $? -eq 0 ];
then
	# service is already running
	echo "Docker Management Web Ui service already running, moving forward"
else
	# check if service is shutdown or not, if shutdown rm the service and then start
	# otherwise it may give duplicate service error (possible)
	echo "Docker Management Web Ui service is not running, check if the service is shutdown"
	docker service ps -f "desired-state=shutdown" "$DOCKER_MANAGEMENT_WEB_UI_SERVICE_NAME" > /dev/null 2>&1
	if [ $? -eq 0 ];
	then
		# service is shutdown and hence exists, remove servcie and recreate
		echo "Docker Management Web Ui service already present in shutdown state, removing and creating new one..."
		echo "Removing the service now.."
		docker service rm "$DOCKER_MANAGEMENT_WEB_UI_SERVICE_NAME"
		echo "Docker Management Web Ui service removed successfully, creating new one..."
		
	else
		# service is not present
		echo "Docker Management Web Ui service is not  present or not in shutdown state, hence creating new one.."
	fi
	# now start the service
	# echo "first pulling image"
	# docker pull portainer/portainer
	# echo "image pulled successfully"
	echo "creating service from image"
	docker service create \
	    --name="$DOCKER_MANAGEMENT_WEB_UI_SERVICE_NAME" \
	    --publish=8082:9000 \
		--constraint=node.role==manager \
	   	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	   	portainer/portainer \
	   	-H unix:///var/run/docker.sock
fi


echo "Docker Manager Web Ui - Portainer started successfully"


# --mount=type=bind,src=/Users/Roy/Documents/Github/sources/public/DevOps/web-management/dev/portainer-data,dst=/data \   	