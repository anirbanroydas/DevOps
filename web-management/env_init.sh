#!/bin/bash

source .env
echo "Environment : $ENVIRONMENT"

if [ "$ENVIRONMENT" == "dev" ]; then
	source $ENV_PATH/$ENVIRONMENT/.env
else
	echo "Cloud Provider : $CLOUD_PROVIDER"
	echo "Provisioning Tool : $PROVISIONING_TOOL"

	source $ENV_PATH/$ENVIRONMENT/$CLOUD_PROVIDER/$PROVISIONING_TOOL/.env
fi


[ -z "$CLUSTER_SIZE" ] &&  CLUSTER_SIZE=3
echo "Cluser Size: ${CLUSTER_SIZE}"

[ -z "$MANAGER_COUNT" ] && MANAGER_COUNT=1
[ -z "$WORKER_COUNT" ] && WORKER_COUNT=2


source $ENV_PATH/$ENVIRONMENT/cluster-node-names

CLUSTER_MANAGER_HOSTNAME=${CLUSTER_MANAGER_NAMES[0]}

# print the cluster swarm manager hostname
echo "Swarm Cluster Manager Hostname : $CLUSTER_MANAGER_HOSTNAME"

# run the provision cluster up script just to safe guard the running cluster
# if the cluster is already running, the script will finish immediately with no side effect
# and if the cluster is not up already then it will go ahead and first create the cluster
# and only then start the swarm view ui manager
echo "Running the provision-cluster-up script to safe guard"
/bin/bash $PATH_TO_PROVISIONING_ENVIRONMENT/provision-cluster-up.sh
echo "Cluster provisioning finished, now beginning swarm view startup"

# read the cluster manager ip 
SWARM_CLUSTER_MANAGER_IP=$(docker-machine ip  "$CLUSTER_MANAGER_HOSTNAME")
echo "Swarm Cluster Manager IP : $SWARM_CLUSTER_MANAGER_IP"

# change environment to cluster manager
echo "changing environment to swarm cluster manager node"
eval $(docker-machine env "$CLUSTER_MANAGER_HOSTNAME")

#check active node
echo "Active Node : $(docker-machine active)"