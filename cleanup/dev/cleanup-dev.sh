#!/bin/bash

[ -z "$CLUSTER_SIZE" ] &&  CLUSTER_SIZE=3
echo "Cluser Size: ${CLUSTER_SIZE}"

ENVIRONMENT="dev"

CLUSTER_NAMES=('nightswatch-manager' 'lannisters-worker' 'starks-worker' 'dothrakis-worker' 'ironborns-worker' 'wildlings-worker' 'whitewalkers-worker')

# cleanup for all the nodes in the swarm cluster
echo "Cleaning up swarm cluster from unrequired/stale/zombie/dangling images, volumes, containers from the entire swarm..."
for i in $(seq 0 $((CLUSTER_SIZE-1)));
do
	echo "cleaning node : ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))..."
	docker-machine ssh "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))" 'echo "y" | docker system prune > /dev/null 2>&1 &' 
	echo "node cleaned succesfully"
done

echo "Cleanup for swarm done succesfully"
