#!/bin/bash

source .env
source $ENV_INIT_SCRIPT_PATH/env_init.sh

# stop machines irrespective of currently running or not, irrespective of node exists or not
# since the error messages are redirected to /dev/null
manager_index=0
worker_index=0

for i in $(seq 0 $((CLUSTER_SIZE-1)));
do

	if [ $i -lt $MANAGER_COUNT ];
	then
		CLUSTER_NODE_NAME=${CLUSTER_MANAGER_NAMES[$manager_index]}-0$((i+1))
		manager_index=$((manager_index + 1))
	else
		CLUSTER_NODE_NAME=${CLUSTER_WORKER_NAMES[$worker_index]}-0$((i+1))
		worker_index=$((worker_index + 1))
	fi

	echo "[$CLUSTER_NODE_NAME] - stopping node..."
	(
		docker-machine stop "$CLUSTER_NODE_NAME" > /dev/null
		echo "[$CLUSTER_NODE_NAME] - node stopped succesfully"
	) &

done


echo "Waiting for nodes to be stopped..."
wait
echo "Nodes Stopeed succesfully"

# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls