#!/bin/bash

export ENV_INIT_SCRIPT_PATH=$HOME/Documents/Github/sources/public/DevOps/provisioning/production

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

	echo "stopping node : $CLUSTER_NODE_NAME..."
	docker-machine stop "$CLUSTER_NODE_NAME" > /dev/null 2>&1
	echo "node stopped succesfully"

done


# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls