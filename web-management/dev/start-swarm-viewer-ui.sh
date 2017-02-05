#!/bin/bash

ENVIRONMENT="dev"
CLUSTER_MANAGER_HOSTNAME="nightswatch-manager-dev-01"
PATH_TO_PROVISIONING_DEV_ENVIRONMENT='/Users/Roy/Documents/Github/sources/public/DevOps/provisioning/dev'

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
echo "first pulling image"
docker pull manomarks/visualizer
echo "image pulled successfully"
echo "creating service from image"
docker service create \
	--name=swarm-viewer-ui \
	--publish=8081:8080/tcp \
	--constraint=node.role==manager \
	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	manomarks/visualizer

echo "Swarm View Ui started successfully"

