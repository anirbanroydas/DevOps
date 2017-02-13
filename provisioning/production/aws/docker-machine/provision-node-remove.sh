#!/bin/bash

source .env

# stop machines irrespective of currently running or not, irrespective of node exists or not
# since the error messages are redirected to /dev/null

echo "[$AWS_NODE_NAME] - stopping and removing node..."
# docker-machine stop "$AWS_NODE_NAME" > /dev/null 2>&1
docker-machine rm --force -y "$AWS_NODE_NAME" > /dev/null 2>&1
echo "[$AWS_NODE_NAME] - node stopped and removed succesfully"

# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls