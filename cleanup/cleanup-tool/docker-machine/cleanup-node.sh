#!/bin/bash

# Cleaning up single node from unrequired/stale/zombie/dangling images, volumes, containers from the entire node.
export NODE_NAME=""


function check_self_node_and_cleanup() {
	echo "checking of current node is a docker node or not"
	NODE_NAME=$(docker info --format '{{json .Name}}' > /dev/null 2>&1)
	
	if [ -z "$NODE_NAME" ]; then
		echo "You are not inside any docker machine, docker host, docker node"
		echo "mention node name as first argument, exiting now"
		# exit 1
	else
		echo "you are in a docker node, now cleaning up the node"
		cleanup "$NODE_NAME"
	fi

}



function check_current_node_and_cleanup() {
	echo "checking of current node is a docker node or not"
	NODE_NAME=$(docker info --format '{{json .Name}}' > /dev/null 2>&1)
	
	if [ -z "$NODE_NAME" ]; then
		echo "You are not inside any docker machine, docker host, docker node, exiting"
		echo "trying to SSH and cleanup"
		ssh_and_cleanup "$1"

	elif [ "$NODE_NAME" = '"$1"' ]; then
		echo "You are already in the mentioned node, starting cleanup"
		cleanup "$1"

	fi

}



function cleanup() {
	echo "[$1] - Cleaning up..."
	echo "Cleaning System Prune..."
	echo "y" | docker system prune > /dev/null 2>&1
	echo "Removing Dangling Volumens"
	docker volume rm $(docker volume ls -q -f  "dangling=true") > /dev/null 2>&1
	echo "Removing exited containers..."
	docker rm $(docker ps -q -f "status=exited") > /dev/null 2>&1 
	echo "Removing exited containers..."
	docker rmi $(docker images -q -f "dangling=true") > /dev/null 2>&1
	echo "node cleaned succesfully"
}



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



# Main Working
if [ "$#" -eq 0 ]; then
	check_self_node_and_cleanup

elif [ "$#" -gt 0 ]; then
	if [ "$1" = "self" ]; then
		check_self_node_and_cleanup
	else
		check_current_node_and_cleanup "$1"
	fi
fi
	

echo "Cleanup Done"
