#!/bin/bash

source env_init.sh

# export CLUSTER_SIZE=3
# export MANAGER_COUNT=1
# export WORKER_COUNT=2
# export MACHINE_DRIVER=virtualbox
# export VIRTUALBOX_MEMORY_SIZE=512
# export VIRTUALBOX_CPU_COUNT=1
# export VIRTUALBOX_DISK_SIZE=10
# export CREATE_SWARM=yes



# --virtualbox-memory	VIRTUALBOX_MEMORY_SIZE	1024
# --virtualbox-cpu-count	VIRTUALBOX_CPU_COUNT	1
# --virtualbox-disk-size	VIRTUALBOX_DISK_SIZE	20000
# --virtualbox-host-dns-resolver	VIRTUALBOX_HOST_DNS_RESOLVER	false
# --virtualbox-boot2docker-url	VIRTUALBOX_BOOT2DOCKER_URL	Latest boot2docker url
# --virtualbox-import-boot2docker-vm	VIRTUALBOX_BOOT2DOCKER_IMPORT_VM	boot2docker-vm
# --virtualbox-hostonly-cidr	VIRTUALBOX_HOSTONLY_CIDR	192.168.99.1/24
# --virtualbox-hostonly-nictype	VIRTUALBOX_HOSTONLY_NIC_TYPE	82540EM
# --virtualbox-hostonly-nicpromisc	VIRTUALBOX_HOSTONLY_NIC_PROMISC	deny
# --virtualbox-no-share	VIRTUALBOX_NO_SHARE	false
# --virtualbox-no-dns-proxy	VIRTUALBOX_NO_DNS_PROXY	false
# --virtualbox-no-vtx-check	VIRTUALBOX_NO_VTX_CHECK	false
# --virtualbox-share-folder	VIRTUALBOX_SHARE_FOLDER	~:users



# create default machine firs if not exists
# echo "Checking if default docker machine exists or not..."
# docker-machine ls -q | grep -w "default" > /dev/null 2>&1
# if [ $? -ne 0 ];
# then
# 	# create the default machine first
# 	echo "default machine does not exist"
# 	echo "creating default machine..."
# 	docker-machine create --driver virtualbox default
# 	echo "defautl machine created"
# 	# now stop it after creating it
# 	echo "default machine is created and started running immediately, hence stopping..."
# 	docker-machine stop default
# 	echo "default machine stopped Successfully"
# else
# 	echo "default machine already exists"
# 	echo "checking machine status, stop if currently running, otherwise move forward"
# 	docker-machine status default | grep -w "Running" > /dev/null 2>&1
# 	if [ $? -eq 0 ];
# 	then
# 		# stop the running defautl machine
# 		echo "default machine is Running, hence stopping..."
# 		docker-machine stop default
# 		echo "default machine stopped Successfully"
# 	else
# 		echo "default machine is already stopped, moving forward"
# 	fi

# fi



export CREATE_STATEMENT="docker-machine create "
export REMOVE="docker-machine rm --force -y "
export START="docker-machine start "
export STOP="docker-machine stop "
export IP="docker-machine ip "



function create_node() {
   echo "creating node..."
   $CREATE $1 2> /dev/null   
   sleep 2
   
   while [ $? -ne 0 ]; do
        $REMOVE $1 > /dev/null 2>&1
        sleep 2
        $CREATE $1 2> /dev/null
        sleep 2
   done
}



function start_node() {
	$START $1 2> /dev/null
	sleep 2
	while [ $? -ne 0 ]; do
		$STOP $1 > /dev/null 2>&1
		sleep 2
		$START $1 2> /dev/null
		sleep 2
	done
}





function change_docker_env_to() {

	eval $(docker-machine env $1)
}



function inspect_docker_node() {

	docker node inspect $1 > /dev/null 2>&1
}






# create docker node onle if not created already
for i in $(seq 0 $((CLUSTER_SIZE-1)));
do
	NODE_TYPE="Worker"
	
	if [ $i -lt $MANAGER_COUNT ];
	then
		NODE_TYPE="Manager"
		CLUSTER_NODE_NAME=${CLUSTER_MANAGER_NAMES[$manager_index]}-0$((i+1))
		manager_index=$((manager_index + 1))
	else
		NODE_TYPE="Worker"
		CLUSTER_NODE_NAME=${CLUSTER_WORKER_NAMES[$worker_index]}-0$((i+1))
		worker_index=$((worker_index + 1))
	fi

	# create the the swarm nodes
	echo "Checking if Swarm ${NODE_TYPE} Node - $CLUSTER_NODE_NAME exists or not..."
	docker-machine ls -q | grep -w "$CLUSTER_NODE_NAME" > /dev/null 2>&1
	if [ $? -ne 0 ];
	then
		# create the swarm node
		echo "creating Swarm ${NODE_TYPE} Node - $CLUSTER_NODE_NAME..."
		create_node  "$CLUSTER_NODE_NAME" 
		echo "Swarm ${NODE_TYPE} Node created: $CLUSTER_NODE_NAME"

	else
		echo "Swarm ${NODE_TYPE} Node - $CLUSTER_NODE_NAME  already exists"
		echo "checking machine status, start if currently stopped, otherwise move forward"
		docker-machine status "$CLUSTER_NODE_NAME" | grep -w "Stopped" > /dev/null 2>&1
		if [ $? -eq 0 ];
		then
			# start the stopped cluster node machine
			echo "$CLUSTER_NODE_NAME machine is Stopped, hence starting..."
			start_node "$CLUSTER_NODE_NAME"
			echo "$CLUSTER_NODE_NAME machine started Successfully"
		else
			echo "$CLUSTER_NODE_NAME machine is already running, moving forward"
		fi
	fi
done



# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls


echo "Checking if swarm to be created or not..."
# proceed with swarm creation only if necesssary
if [ "$CREATE_SWARM" == "yes" ]; then

	MAIN_SWARM_MANAGER=${CLUSTER_MANAGER_NAMES[0]}-01
	echo "MAIN_SWARM_MANAGER : $MAIN_SWARM_MANAGER"
	MAIN_SWARM_MANAGER_IP=$(IP "$MAIN_SWARM_MANAGER")
	echo "Main Swarm Manager IP : $MAIN_SWARM_MANAGER_IP"

	# change docker machine env to main swarm manager
	change_docker_env_to "$MAIN_SWARM_MANAGER"

	# check active machine status again
	echo "Active Machine : $(docker-machine active)"

	# init swarm (need for service command); if not created
	echo "Checking if Swarm is already initialized..."
	docker node ls > /dev/null 2>&1 | grep "Leader"
	if [ $? -ne 0 ]; 
	then
		# initialize swarm mode
		echo "Swarm not initialzed, hence starting..."
		echo "Initializing Swarm..."
		docker swarm init --advertise-addr "$MAIN_SWARM_MANAGER_IP" > /dev/null 2>&1
		echo "Swarm Initialized"
	else
		echo "Swarm already initailized, moving forward"
	fi


	# save the swarm token to use in the rest of the nodes
	SWARM_WORKER_JOIN_TOKEN=$(docker swarm join-token -q worker)
	SWARM_MANAGER_JOIN_TOKEN=$(docker swarm join-token -q manager)

	# initialize the managers to join the swarm
	# but, before that check if the node has already joined the swarm as manager or not
	manager_index=1
	worker_index=0

	echo "Checking if the rest of the nodes are initialized, if yes, move forward, else join the swarm"
	for i in $(seq 1 $((CLUSTER_SIZE-1)));
	do

		if [ $i -lt $MANAGER_COUNT ];
		then
			CLUSTER_NODE_NAME=${CLUSTER_MANAGER_NAMES[$manager_index]}-0$((i+1))
			SWARM_JOIN_TOKEN=$SWARM_MANAGER_JOIN_TOKEN
			manager_index=$((manager_index + 1))
		else
			CLUSTER_NODE_NAME=${CLUSTER_WORKER_NAMES[$worker_index]}-0$((i+1))
			SWARM_JOIN_TOKEN=$SWARM_WORKER_JOIN_TOKEN
			worker_index=$((worker_index + 1))
		fi

		inspect_docker_node "$CLUSTER_NODE_NAME"
	    if [ $? -ne 0 ]; 
		then
			echo "$CLUSTER_NODE_NAME node have not joined $MAIN_SWARM_MANAGER manager"
			echo "$CLUSTER_NODE_NAME node joining $MAIN_SWARM_MANAGER manager"
			change_docker_env_to "$MAIN_SWARM_MANAGER"
			echo "Active Machine : $(docker-machine active)"
			echo "$CLUSTER_NODE_NAME node joining swarm mananger $MAIN_SWARM_MANAGER..."
			# first leave any previous swarm if at all
			docker swarm leave  > /dev/null 2>&1
			docker swarm join --token  "$SWARM_JOIN_TOKEN"  "$MANAGER_IP":2377
			echo "$CLUSTER_NODE_NAME joined swarm managed by $MAIN_SWARM_MANAGER"
		else
			echo "$CLUSTER_NODE_NAME node already joined $MAIN_SWARM_MANAGER manager, moving forward"
		fi

		change_docker_env_to "$CLUSTER_NODE_NAME"
		echo "Active Machine : $(docker-machine active)"

	done
	echo "Swarm Initialization Completed"
	echo "Current Swarm Nodes:"
	docker node ls

else 

	 echo "Swarm Creation Not Required, moving forward"
fi



manager_index=0
worker_index=0

echo "Dns management for all the nodes im the swarm"
# add dns nameservers pointing to google nameservers in /etc/resolv.conf due to a bug/error
# whcih does not allow to pull images from docker registry (using docker version 1.13.0)
for i in $(seq 0 $((CLUSTER_SIZE-1)));
do

	if [ $i -lt $MANAGER_COUNT ];
	then
		CLUSTER_NODE_NAME=${CLUSTER_MANAGER_NAMES[$manager_index]}-0$((i+1))
		manager_index=$((manager_index + 1))
	else
		CLUSTER_NODE_NAME=${CLUSTER_WORKER_NAMES[$worker_index]}-0$((i+1))
		worker_index=$((worker_index + 1))
	fi

	echo "adding dns entry to /etc/resolv.conf for swarm node : $CLUSTER_NODE_NAME"
	docker-machine ssh "$CLUSTER_NODE_NAME" \
	'echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo  cat - /etc/resolv.conf > /tmp/out_etc_resolv \
	&&  sudo mv /tmp/out_etc_resolv  /etc/resolv.conf \
	&& sudo rm -f /tmp/out_etc_resolv >/dev/null 2>&1 &'
	
	echo "dns entry added successfully for $CLUSTER_NODE_NAME"

done





echo "Provisioning Successful"

# trap time EXIT

