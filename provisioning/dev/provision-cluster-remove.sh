#!/bin/bash

[ -z "$CLUSTER_SIZE" ] &&  CLUSTER_SIZE=3
echo "Cluser Size: ${CLUSTER_SIZE}"

ENVIRONMENT="dev"

CLUSTER_NAMES=('nightswatch-manager' 'lannisters-worker' 'starks-worker' 'dothrakis-worker' 'ironborns-worker' 'wildlings-worker' 'whitewalkers-worker')

# stop machines irrespective of currently running or not, irrespective of node exists or not
# since the error messages are redirected to /dev/null
for i in $(seq 0 $((CLUSTER_SIZE-1)));
do
	echo "stopping and removing node : ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))..."
	docker-machine stop "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))" > /dev/null 2>&1
	docker-machine rm "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))" > /dev/null 2>&1
	echo "node stopped and removed succesfully"
done

# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls