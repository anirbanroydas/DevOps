#!/bin/bash

source env_init.sh

# start the visualizer service in the swarm manager node
echo "Starting Swarm View Ui..."

# first check if the service is already running or not
# if running then move on, otherwise create the service
echo "First, checking if service is already running or not..."
docker service ps -f "desired-state=running" "$SWARM_VIEWER_UI_SERVICE_NAME" > /dev/null 2>&1
if [ $? -eq 0 ];
then
	# service is already running
	echo "Swarm Viewer Ui service already running, moving forward"
else
	# check if service is shutdown or not, if shutdown rm the service and then start
	# otherwise it may give duplicate service error (possible)
	echo "Swarm Viewwer UI service is not running, check if the service is shutdown"
	docker service ps -f "desired-state=shutdown" "$SWARM_VIEWER_UI_SERVICE_NAME" > /dev/null 2>&1
	if [ $? -eq 0 ];
	then
		# service is shutdown and hence exists, remove servcie and recreate
		echo "Swarm Viewwer UI service already present in shutdown state, removing and creating new one..."
		echo "Removing the service now.."
		docker service rm "$SWARM_VIEWER_UI_SERVICE_NAME"
		echo "Swarm Viewer Ui service removed successfully, creating new one..."
		
	else
		# service is not present
		echo "Swarm Viewer UI service is not  present or not in shutdown state, hence creating new one.."
	fi
	# now start the service
	# echo "first pulling image"
	# docker pull manomarks/visualizer
	# echo "image pulled successfully"
	echo "creating service from image"
	docker service create \
		--name="$SWARM_VIEWER_UI_SERVICE_NAME" \
		--publish=8081:8080/tcp \
		--constraint=node.role==manager \
		--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
		manomarks/visualizer
fi

echo "Swarm View Ui started successfully"

