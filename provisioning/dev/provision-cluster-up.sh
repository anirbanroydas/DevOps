#!/bin/bash

# set -e

[ -z "$CLUSTER_SIZE" ] &&  CLUSTER_SIZE=3
echo "Cluser Size: ${CLUSTER_SIZE}"

ENVIRONMENT="dev"

CLUSTER_NAMES=('nightswatch-manager' 'lannisters-worker' 'starks-worker' 'dothrakis-worker' 'ironborns-worker' 'wildlings-worker' 'whitewalkers-worker')


# create default machine firs if not exists
echo "Checking if default docker machine exists or not..."
docker-machine ls -q | grep -w "default" > /dev/null 2>&1
if [ $? -ne 0 ];
then
	# create the default machine first
	echo "default machine does not exist"
	echo "creating default machine..."
	docker-machine create --driver virtualbox default
	echo "defautl machine created"
	# now stop it after creating it
	echo "default machine is created and started running immediately, hence stopping..."
	docker-machine stop default
	echo "default machine stopped Successfully"
else
	echo "default machine already exists"
	echo "checking machine status, stop if currently running, otherwise move forward"
	docker-machine status default | grep -w "Running" > /dev/null 2>&1
	if [ $? -eq 0 ];
	then
		# stop the running defautl machine
		echo "default machine is Running, hence stopping..."
		docker-machine stop default
		echo "default machine stopped Successfully"
	else
		echo "default machine is already stopped, moving forward"
	fi

fi


# create a docker swarm cluster of 3 nodes - 1 master and  2 worker
for i in $(seq 0 $((CLUSTER_SIZE-1)));
do
	NODE_TYPE="Worker"
	
	if [ $i -eq 0 ];
	then
		NODE_TYPE="Manager"
	fi

	# create the the swarm nodes
	echo "Checking if Swarm ${NODE_TYPE} Node - ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1)) exists or not..."
	docker-machine ls -q | grep -w "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))" > /dev/null 2>&1
	if [ $? -ne 0 ];
	then
		# create the swarm node
		echo "creating Swarm ${NODE_TYPE} Node - ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))..."
		docker-machine create --driver virtualbox "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))"
		echo "Swarm ${NODE_TYPE} Node created: ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))"

	else
		echo "Swarm ${NODE_TYPE} Node - ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))  already exists"
		echo "checking machine status, start if currently stopped, otherwise move forward"
		docker-machine status "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))" | grep -w "Stopped" > /dev/null 2>&1
		if [ $? -eq 0 ];
		then
			# start the stopped cluster node machine
			echo "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1)) machine is Stopped, hence starting..."
			docker-machine start "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))"
			echo "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1)) machine started Successfully"
		else
			echo "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1)) machine is already running, moving forward"
		fi
	fi
done


# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls

MANAGER_IP=$(docker-machine ip "${CLUSTER_NAMES[0]}-${ENVIRONMENT}-01")
echo "Swarm Manager IP : ${MANAGER_IP}"

# change docker machine env to swarm manager
eval $(docker-machine env "${CLUSTER_NAMES[0]}-${ENVIRONMENT}-01")

# check active machine status again
echo "Active Machine : $(docker-machine active)"

# init swarm (need for service command); if not created
echo "Checking if Swarm is already initialized..."
docker node ls 2> /dev/null | grep "Leader"
if [ $? -ne 0 ]; 
then
	# initialize swarm mode
	echo "Swarm not initialzed, hence starting..."
	echo "Initializing Swarm..."
	docker swarm init --advertise-addr ${MANAGER_IP} > /dev/null 2>&1
	echo "Swarm Initialized"
else
	echo "Swarm already initailized, moving forward"
fi


# save the swarm token to use in the rest of the nodes
SWARM_WORKER_JOIN_TOKEN=$(docker swarm join-token -q worker)

# initialize the worker to join the swarm
# but, before that check if the node has already joined the swarm or not
for i in $(seq 1 $((CLUSTER_SIZE-1)));
do
	docker node inspect "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))" 2>1 1> /dev/null
	if [ $? -ne 0 ]; 
	then
		echo "${CLUSTER_NAMES[$i]} worker have not joined ${CLUSTER_NAMES[0]} manager"
		echo "${CLUSTER_NAMES[$i]} worker joining ${CLUSTER_NAMES[0]} manager"
		eval $(docker-machine env "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))")
		echo "Active Machine : $(docker-machine active)"
		echo "${CLUSTER_NAMES[$i]} worker joining swarm mananger ${CLUSTER_NAMES[0]}..."
		# first leave any previous swarm if at all
		docker swarm leave 1>2 2> /dev/null
		docker swarm join --token ${SWARM_WORKER_JOIN_TOKEN} ${MANAGER_IP}:2377
		echo "${CLUSTER_NAMES[$i]} joined swarm managed by ${CLUSTER_NAMES[0]}"
	else
		echo "${CLUSTER_NAMES[$i]} worker already joined ${CLUSTER_NAMES[0]} manager, moving forward"
	fi


	eval $(docker-machine env "${CLUSTER_NAMES[0]}-${ENVIRONMENT}-01")
	echo "Active Machine : $(docker-machine active)"

done

# add dns nameservers pointing to google nameservers in /etc/resolv.conf due to a bug/error
# whcih does not allow to pull images from docker registry (using docker version 1.13.0)
for i in $(seq 0 $((CLUSTER_SIZE-1)));
do

	echo "adding dns entry to /etc/resolv.conf for swarm node : ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))"
	docker-machine ssh "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))" \
	'echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo  cat - /etc/resolv.conf > /tmp/out_etc_resolv \
	&&  sudo mv /tmp/out_etc_resolv  /etc/resolv.conf \
	&& sudo rm -f /tmp/out_etc_resolv >/dev/null 2>&1 &'
	echo "dns entry added successfully for ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))"

done

echo "Current Swarm Nodes:"
docker node ls

echo "Provisioning Successful"

# trap time EXIT

