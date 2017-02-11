#!/bin/bash

source .env

source $ENV_INIT_SCRIPT_PATH/env_init.sh

# cleanup for all the nodes in the swarm cluster
echo "Cleaning up swarm cluster from unrequired/stale/zombie/dangling images, volumes, containers from the entire swarm..."
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

	echo "cleaning node : $CLUSTER_NODE_NAME..."
	(
		docker-machine ssh "$CLUSTER_NODE_NAME" 'echo "y" | docker system prune > /dev/null 2>&1 &' 
		echo "node cleaned succesfully"
	) &

done

echo "wating for swarm cleanup..."
wait
echo "Cleanup for swarm done succesfully"
