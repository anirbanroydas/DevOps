#!/bin/bash

source .env

# stop machines irrespective of currently running or not, irrespective of node exists or not
# since the error messages are redirected to /dev/null

echo "[$AWS_NODE_NAME] - stopping node..."
docker-machine stop "$AWS_NODE_NAME" > /dev/null 2>&1
echo "[$AWS_NODE_NAME] - node stopped succesfully"


# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls