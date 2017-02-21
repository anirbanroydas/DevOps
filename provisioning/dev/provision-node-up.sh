#!/bin/bash

source env_init.sh

if [ "$#" -eq 1 ]; then
	export NODE_NAME="$1"
fi

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


export MAIN_SWARM_MANAGER=${NODE_NAME}
echo "MAIN_SWARM_MANAGER : $MAIN_SWARM_MANAGER"
export MAIN_SWARM_MANAGER_NEW="no"


export CREATE="docker-machine create "
export REMOVE="docker-machine rm --force -y "
export START="docker-machine start "
export STOP="docker-machine stop "
export IP="docker-machine ip "



function create_node() {
   	echo "creating node"
   	echo "$CREATE $1"

   	if [ "$MAIN_SWARM_MANAGER" == "$1" ]; then
		MAIN_SWARM_MANAGER_NEW="yes"
	fi
   
   	$CREATE $1

}



function start_node() {

	if [ "$MAIN_SWARM_MANAGER" == "$1" ]; then
		MAIN_SWARM_MANAGER_NEW="yes"
	fi
	
	$START $1 > /dev/null
	
}





function change_docker_env_to() {

	eval $(docker-machine env $1) > /dev/null
	if [ $? -ne 0 ]; then
		echo "Error in changing docker environment, regenerating certs..."
		docker-machine regenerate-certs --force $1
		eval $(docker-machine env $1) > /dev/null
	fi
}



function inspect_docker_node() {

	docker-machine ssh $1 sudo docker node inspect $2 > /dev/null 2>&1
}






# create docker node onle if not created already
NODE_TYPE=${SWARM_NODE_TYPE}

# create the the  node
echo "[$NODE_NAME ] - Checking if  Node exists or not..."
docker-machine ls -q | grep -w "$NODE_NAME" > /dev/null 2>&1
if [ $? -ne 0 ];
then
	# create the swarm node
	echo "[$NODE_NAME] - creating  Node..."
	(
		create_node  "$NODE_NAME" 
		echo "[$NODE_NAME] - Node created"
	)

else
	echo "[$NODE_NAME] - Node already exists"
	echo "[$NODE_NAME] - checking Node status, start if currently stopped, otherwise move forward"
	(
		docker-machine status "$NODE_NAME" | grep -w "Stopped" > /dev/null 2>&1
		if [ $? -eq 0 ];
		then
			# start the stopped cluster node machine
			echo "[$NODE_NAME] machine is Stopped, hence starting..."
			start_node "$NODE_NAME"
			echo "[$NODE_NAME] machine started Successfully"
		else
			echo "[$NODE_NAME] machine is already running, moving forward"
		fi
	) &
fi



echo "Wating for node creation..."
wait
echo "Node Created"


# list the cluster machines
echo "Current Docker Hosts:"
docker-machine ls


echo "Checking if swarm to be created or not..."
# proceed with swarm creation only if necesssary
if [ "$SWARM_MODE_NODE" == "yes" ]; then

	

	# change docker machine env to main swarm manager
	# change_docker_env_to "$MAIN_SWARM_MANAGER"

	# check active machine status again
	# echo "Active Machine : $(docker-machine active)"

	# init swarm (need for service command); if not created
	echo "Checing if swarm node to be initialized or not"
	if [ "$CREATE_SWARM_NODE" == "yes" ]; then
		
		export MAIN_SWARM_MANAGER=${NODE_NAME}
		echo "MAIN_SWARM_MANAGER : $MAIN_SWARM_MANAGER"
		export MAIN_SWARM_MANAGER_IP=$(docker-machine ip  "$MAIN_SWARM_MANAGER")
		echo "Main Swarm Manager IP : $MAIN_SWARM_MANAGER_IP"

		# init swarm (need for service command); if not created
		echo "Checking if Swarm is needs to be initialized or not"
		if [ "$MAIN_SWARM_MANAGER_NEW" == "yes" ]; then
			echo "Main Swarm Manger Node has been created/started, hence new ip, thus reinitialzing swarm"
			echo "First leaving previous swarm, if any"
			docker-machine ssh "$MAIN_SWARM_MANAGER" <<- EOSSH
				sudo docker swarm leave --force > /dev/null 2>&1
				echo "Initializing new swarm..."
				sudo docker swarm init --advertise-addr "$MAIN_SWARM_MANAGER_IP" > /dev/null
				echo "Swarm Initialized"
			EOSSH
		else 
			# initialize swarm only if it is already not initialzed
			echo "Main Swarm Manager has not been creted or restarded, hence now checking if swarm is already initialzed or not.."
			docker-machine ssh "$MAIN_SWARM_MANAGER" <<- EOSSH
				sudo docker node ls 2> /dev/null | grep "Leader" > /dev/null 2>&1
				if [ $? -ne 0 ]; 
				then
					# initialize swarm mode
					echo "Swarm not initialzed, hence starting..."
					echo "Initializing Swarm..."
					sudo docker swarm init --advertise-addr "$MAIN_SWARM_MANAGER_IP" > /dev/null
					echo "Swarm Initialized"
				else
					echo "Swarm already initailized, moving forward"
				fi
			EOSSH
		fi

	else 
		echo "Checking if the the node is initialzed to swarm, if yes, \
		move forward, else join the swarm either as manager or worker as mentioned in config"	
		
		SWARM_JOIN_TOKEN=$SWARM_TOKEN

		echo "[$NODE_NAME] - Inspecting..."
		(
			
			echo "$NODE_NAME node joining swarm mananger..."
			# first leave any previous swarm if at all
			docker-machine ssh "$NODE_NAME" <<- EOSSH
				sudo docker swarm leave --force > /dev/null 2>&1
				sudo docker swarm join --token  "$SWARM_JOIN_TOKEN"  "$MAIN_SWARM_MANAGER_IP":2377 > /dev/null
				echo "$NODE_NAME joined swarm manager"
			EOSSH
		
		) &


		echo "Wating for swarm creation..."
		wait
		echo "Swarm Nodes Initialization completed"

	fi
	
else 

	 echo "Swarm Creation Not Required, moving forward"
fi




if [ "$CONFIGURATION" == "yes"]; then

	echo "Configuring Each Node..."
	# install docker-compose in each node
	echo "[$NODE_NAME] - processing for swarm node..."
	(
		docker-machine ssh "$NODE_NAME"  <<- EOSSH
			# echo "[$CLUSTER_NODE_NAME] - Adding Dns Entry..."
			# echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf >/dev/null 2>&1
			# echo "[$CLUSTER_NODE_NAME] - dns entry added successfully"	


			if ! which docker-compose > /dev/null 2>&1; then 
				echo "[$NODE_NAME] - Installing docker-compose..."
				sudo curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" \
				-o /usr/local/bin/docker-compose > /dev/null 
				sudo chmod +x /usr/local/bin/docker-compose
			else
				echo "[$NODE_NAME] - docker-compose already installed, moving forward"
			fi
			

			if ! which rexray > /dev/null 2>&1; then 
				echo "[$NODE_NAME] - Installing Rex-Ray"
				curl -sSL https://dl.bintray.com/emccode/rexray/install | sh
				echo "[$NODE_NAME] - Rex-Ray Installed"
				
			else
				echo "[$NODE_NAME] - Rex-Ray Already INstalled, moving forward"
			fi

			echo "[$NODE_NAME] - Configuring Rex-Ray"
			sudo tee /etc/rexray/config.yml << EOF
			rexray:
			  logLevel: warn
			libstorage:
			  logging:
			    level: warn
			  service: virtualbox
			  integration:
			    volume:
			      operations:
			        create:
			          default:
			            size: 8
			        mount:
			          preempt: true
			        unmount: 
			          ignoreUsedCount: false
			        path:
			          cache:
			            enabled: true
			            async: true
			virtualbox:
			  endpoint: http://192.168.99.1:18083
			  tls: true
			  volumePath: /Users/Roy/VirtualBox/Volumes
			  controllerName: SATA
			  localMachineNameOrId: $NODE_NAME
			EOF
			echo "[$NODE_NAME] - Rex-Ray configured"
			
			echo "[$NODE_NAME] - Rex-Ray Restarting"
			sudo rexray start > /dev/null
			echo "[$NODE_NAME] - Rex-Ray Restarted Successfully"

			echo "[$NODE_NAME] - processing done"
		
		EOSSH

		# echo "[$NODE_NAME] - Configuring Rex-Ray"
		# docker-machine ssh "$NODE_NAME"  sudo tee /etc/rexray/config.yml < "$STORAGE_PROVISION_CONFIG_FILE" > /dev/null 2>&1
		# echo "[$NODE_NAME] - Rex-Ray configured"
		# echo "[$NODE_NAME] - Rex-Ray Restarting"
		# docker-machine ssh "$NODE_NAME" sudo rexray start > /dev/null 2>&1
		# echo "[$NODE_NAME] - Rex-Ray Restarted Successfully"

		# echo "[$NODE_NAME] - processing done"

	) &


	echo "Wating for configuration of nodes..."
	wait
	echo "configuration of all nodes completed"

else
	echo "Configuration not required, moving forward"
fi

echo "Starting Virtualbox SOAP API to accept API requests from the REX-Ray service..."
if pgrep -x vboxwebsrv > /dev/null; then
	echo "Virutalbpx SOAP API Service already running, moving forward"
else
	echo "Strating..."
	# VboxCommand="vboxwebsrv -H 0.0.0.0 -v"
	# nohup $VboxCommand &
	vboxwebsrv -H 0.0.0.0 -v -b
	echo "Virtualbox SOAP API webservice started"
fi




echo "Provisioning Successful"

