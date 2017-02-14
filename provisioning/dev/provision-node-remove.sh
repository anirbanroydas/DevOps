#!/bin/bash

source .env

# stop machines irrespective of currently running or not, irrespective of node exists or not
# since the error messages are redirected to /dev/null

if [ "$#" -eq 1 ]; then
	export NODE_NAME="$1"
fi

echo "[$NODE_NAME] - stopping and removing node..."
# docker-machine stop "$NODE_NAME" > /dev/null 2>&1
docker-machine rm --force -y "$NODE_NAME" > /dev/null 2>&1
echo "[$NODE_NAME] - node stopped and removed succesfully"

# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls