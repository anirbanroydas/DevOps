#!/bin/bash

# set -e

[ -z "$CLUSTER_SIZE" ] &&  CLUSTER_SIZE=3
echo "Cluser Size: ${CLUSTER_SIZE}"

# create default machine firs if not exists
echo "Checking if default docker machine exists or not..."
docker-machine ls -q | grep -w "default" 1>2
if [ $? -ne 0 ];
then
	# create the default machine first
	echo "default machine does not exist"
	echo "creating default machine..."
	docker-machine create --driver virtualbox default
	echo "defautl machine created"
else
	echo "default machine already exists"
	echo "checking machine status, stop if currently running, otherwise move forward"
	docker-machine status default | grep -w "Running" 1>2
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

# stop the docker default machine


# create a docker swarm cluster of 3 nodes - 1 master and  2 worker

# create the swarm manager if not exists
echo "Checking if SWARM MANAGER NODE exists or not..."
docker-machine ls -q | grep -w "nightswatch-manager-dev-01" 1>2
if [ $? -ne 0 ];
then
	# create the swarm manager node
	echo "creating SWARM MANAGER NODE - nightswatch..."
	docker-machine create --driver virtualbox nightswatch-manager-dev-01
	echo "Swarm Manager Node created: nightswatch-manager-dev-01"
else
	echo "Swarm Manager Node already exist"
	echo "checking machine status, start if currently stopped, otherwise move forward"
	docker-machine status nightswatch-manager-dev-01 | grep -w "Stopped" 1>2
	if [ $? -eq 0 ];
	then
		# stop the running defautl machine
		echo "nightswatch-manager-dev-01 machine is Stopped, hence starting..."
		docker-machine start nightswatch-manager-dev-01
		echo "nightswatch-manager-dev-01 machine started Successfully"
	else
		echo "nightswatch-manager-dev-01 machine is already running, moving forward"
	fi
fi

# create the rest of the worker nodes
echo "Checking if Worker NODE - lannisters exists or not..."
docker-machine ls -q | grep -w "lannisters-worker-dev-02" 1>2
if [ $? -ne 0 ];
then
	# create the swarm worke node
	echo "creating SWARM WORKER NODE - lannisters..."
	docker-machine create --driver virtualbox lannisters-worker-dev-02
	echo "Swarm Worker Node created: lannisters-worker-dev-02"

else
	echo "Swarm Worker Node - lannisters  already exists"
	echo "checking machine status, start if currently stopped, otherwise move forward"
	docker-machine status lannisters-worker-dev-02 | grep -w "Stopped" 1>2
	if [ $? -eq 0 ];
	then
		# stop the running defautl machine
		echo "lannisters-worker-dev-02 machine is Stopped, hence starting..."
		docker-machine start lannisters-worker-dev-02
		echo "lannisters-worker-dev-02 machine started Successfully"
	else
		echo "lannisters-worker-dev-02 machine is already running, moving forward"
	fi
fi


echo "Checking if Worker NODE - starks exists or not..."
docker-machine ls -q | grep -w "starks-worker-dev-03" 1>2
if [ $? -ne 0 ];
then
	# create the swarm worke node
	echo "creating SWARM WORKER NODE - starks..."
	docker-machine create --driver virtualbox starks-worker-dev-03
	echo "Swarm Worker Node created: starks-worker-dev-02"

else
	echo "Swarm Worker Node - starks  already exists"
	echo "checking machine status, start if currently stopped, otherwise move forward"
	docker-machine status starks-worker-dev-03 | grep -w "Stopped" 1>2
	if [ $? -eq 0 ];
	then
		# stop the running defautl machine
		echo "starks-worker-dev-03 machine is Stopped, hence starting..."
		docker-machine start starks-worker-dev-03
		echo "starks-worker-dev-03 machine started Successfully"
	else
		echo "starks-worker-dev-03 machine is already running, moving forward"
	fi
fi


# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls

MANAGER_IP=$(docker-machine ip nightswatch-manager-dev-01)
echo "Swarm Manager IP : ${MANAGER_IP}"

# change docker machine env to swarm manager
eval $(docker-machine env nightswatch-manager-dev-01)

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
docker node inspect lannisters-worker-dev-02 2>1 1> /dev/null
if [ $? -ne 0 ]; 
then
	echo "lannisters worker have not joined nightswatch manager"
	echo "lannisters worker joining nightswatch manager"
	eval $(docker-machine env lannisters-worker-dev-02)
	echo "Active Machine : $(docker-machine active)"
	echo "lannisters worker joining swarm mananger nightswatch..."
	# first leave any previous swarm if at all
	docker swarm leave 1>2 2> /dev/null
	docker swarm join --token ${SWARM_WORKER_JOIN_TOKEN} ${MANAGER_IP}:2377
	echo "lannisters joined swarm managed by nightswatch"
else
	echo "lannisters worker already joined nightswatch manager, moving forward"
fi


eval $(docker-machine env nightswatch-manager-dev-01)
echo "Active Machine : $(docker-machine active)"

docker node inspect starks-worker-dev-03 2>1 1> /dev/null
if [ $? -ne 0 ]; 
then
	echo "starks worker have not joined nightswatch manager"
	echo "starks worker joining nightswatch manager"	
	eval $(docker-machine env starks-worker-dev-03)
	echo "Active Machine : $(docker-machine active)"
	echo "starks worker joining swarm mananger nightswatch..."
	# first leave any previous swarm if at all
	docker swarm leave 1>2 2> /dev/null
	docker swarm join --token ${SWARM_WORKER_JOIN_TOKEN} ${MANAGER_IP}:2377
	echo "starks joined swarm managed by nightswatch"
else
	echo "starks worker already joined nightswatch manager, moving forward"
fi


# make swarm manager active again
eval $(docker-machine env nightswatch-manager-dev-01)
echo "Active Machine : $(docker-machine active)"
echo "Current Swarm Nodes:"
docker node ls

echo "Provisioning Successful"

# trap time EXIT

