#!/bin/bash

source .env

# stop machines irrespective of currently running or not, irrespective of node exists or not
# since the error messages are redirected to /dev/null

echo "[$NODE_NAME] - stopping node..."
docker-machine stop "$NODE_NAME" > /dev/null 2>&1
echo "[$NODE_NAME] - node stopped succesfully"


# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls