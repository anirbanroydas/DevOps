#!/bin/bash

source .env
source $ENV_INIT_SCRIPT_PATH/env_init.sh

# stop machines irrespective of currently running or not, irrespective of node exists or not
# since the error messages are redirected to /dev/null
manager_index=0
worker_index=0

for i in $(seq 0 $((CLUSTER_SIZE-1)));
do

	# if [ $i -lt $MANAGER_COUNT ];
	# then
	# 	CLUSTER_NODE_NAME=${CLUSTER_MANAGER_NAMES[$manager_index]}-0$((i+1))
	# 	manager_index=$((manager_index + 1))
	# else
	# 	CLUSTER_NODE_NAME=${CLUSTER_WORKER_NAMES[$worker_index]}-0$((i+1))
	# 	worker_index=$((worker_index + 1))
	# fi

	if [ $i -gt 8 ]; then
		CLUSTER_NODE_NAME=prod-$((i+1))
	else
		CLUSTER_NODE_NAME=prod-0$((i+1))
	fi

	echo "[$CLUSTER_NODE_NAME] - stopping and removing node..."
	(
		
		docker-machine rm --force -y "$CLUSTER_NODE_NAME" > /dev/null
		echo "[$CLUSTER_NODE_NAME] - node stopped and removed succesfully"
	) &

done


echo "Waiting for nodes to be removed..."
wait
echo "Nodes Removed succesfully"

# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls