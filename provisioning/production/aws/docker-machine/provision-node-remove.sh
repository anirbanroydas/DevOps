#!/bin/bash

source .env

# stop machines irrespective of currently running or not, irrespective of node exists or not
# since the error messages are redirected to /dev/null

if [ "$#" -eq 1 ]; then
	export AWS_NODE_NAME="$1"
fi


echo "[$AWS_NODE_NAME] - stopping and removing node..."
docker-machine rm --force -y "$AWS_NODE_NAME" > /dev/null
echo "[$AWS_NODE_NAME] - node stopped and removed succesfully"

# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls