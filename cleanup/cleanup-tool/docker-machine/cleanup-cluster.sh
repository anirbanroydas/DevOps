#!/bin/bash

source .env

source $ENV_INIT_SCRIPT_PATH/env_init.sh

# cleanup for all the nodes in the swarm cluster
echo "Cleaning up swarm cluster from unrequired/stale/zombie/dangling images, volumes, containers from the entire swarm..."


function ssh_and_cleanup() {

	docker-machine ssh "$1" <<- EOSSH
		echo "[$1] - Cleaning System Prune..."
		echo "y" | docker system prune > /dev/null 2>&1
		echo "[$1] - Removing Dangling Volumens"
		docker volume rm $(docker volume ls -q -f  "dangling=true") > /dev/null 2>&1
		echo "[$1] - Removing exited containers..."
		docker rm $(docker ps -q -f "status=exited") > /dev/null 2>&1 
		echo "[$1] - Removing exited containers..."
		docker rmi $(docker images -q -f "dangling=true") > /dev/null 2>&1
		echo "[$1] - node cleaned succesfully"
	EOSSH

}



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

	echo "[$CLUSTER_NODE_NAME] cleaning node..."
	(
		ssh_and_cleanup "$CLUSTER_NODE_NAME"
	) &

done

echo "wating for swarm cleanup..."
wait
echo "Cleanup for swarm done succesfully"
