#!/bin/bash

ENVIRONMENT="dev"
CLUSTER_MANAGER_HOSTNAME="nightswatch-manager-dev-01"
PATH_TO_PROVISIONING_DEV_ENVIRONMENT='/Users/Roy/Documents/Github/sources/public/DevOps/provisioning/dev'
SWARM_VIEWER_UI_SERVICE_NAME="swarm-viewer-ui"

# print the cluster swarm manager hostname
echo "Swarm Cluster Manager Hostname : $CLUSTER_MANAGER_HOSTNAME"


# run the provision cluster up script just to safe guard the running cluster
# if the cluster is already running, the script will finish immediately with no side effect
# and if the cluster is not up already then it will go ahead and first create the cluster
# and only then start the swarm view ui manager
echo "Running the provision-cluster-up script to safe guard"
/bin/bash $PATH_TO_PROVISIONING_DEV_ENVIRONMENT/provision-cluster-up.sh
echo "Cluster provisioning finished, now beginning swarm view startup"

# read the cluster manager ip 
SWARM_CLUSTER_MANAGER_IP=$(docker-machine ip  "$CLUSTER_MANAGER_HOSTNAME")
echo "Swarm Cluster Manager IP : $SWARM_CLUSTER_MANAGER_IP"

# change environment to cluster manager
echo "changing environment to swarm cluster manager node"
eval $(docker-machine env "$CLUSTER_MANAGER_HOSTNAME")

#check active node
echo "Active Node : $(docker-machine active)"

# start the visualizer service in the swarm manager node
echo "Starting Swarm View Ui..."

# first check if the service is already running or not
# if running then move on, otherwise create the service
echo "First, checking if service is already running or not..."
docker service ps -f "desired-state=running" "$SWARM_VIEWER_UI_SERVICE_NAME"
if [ $? -eq 0 ];
then
	# service is already running
	echo "Swarm Viewer Ui service already running, moving forward"
else
	# check if service is shutdown or not, if shutdown rm the service and then start
	# otherwise it may give duplicate service error (possible)
	echo "Swarm Viewwer UI service is not running, check if the service is shutdown"
	docker service ps -f "desired-state=shutdown" "$SWARM_VIEWER_UI_SERVICE_NAME"
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
	echo "first pulling image"
	docker pull manomarks/visualizer
	echo "image pulled successfully"
	echo "creating service from image"
	docker service create \
		--name="$SWARM_VIEWER_UI_SERVICE_NAME" \
		--publish=8081:8080/tcp \
		--constraint=node.role==manager \
		--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
		manomarks/visualizer
fi

echo "Swarm View Ui started successfully"

