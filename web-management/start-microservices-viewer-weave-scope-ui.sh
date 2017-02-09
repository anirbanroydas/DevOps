#!/bin/bash

# # start weave scope for each node in the swarm cluster
# echo "Starting Weave Scope for each node in the swarm cluster..."
# for i in $(seq 0 $((CLUSTER_SIZE-1)));
# do
# 	echo "processing node : ${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))..."
	
# 	# change environment to cluster manager
# 	echo "changing environment to swarm cluster manager node"
# 	eval $(docker-machine env "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))")

# 	#check active node
# 	echo "Active Node : $(docker-machine active)"

# 	# first check if the service is already running or not
# 	# if running then move on, otherwise create the service
# 	echo "First, checking if service is already running or not..."
# 	docker service ps -f "desired-state=running" "$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME" > /dev/null 2>&1
# 	if [ $? -eq 0 ];
# 	then
# 		# service is already running
# 		echo "Microservices Viewer Weave Scope Web UI service already running, moving forward"
# 	else
# 		# check if service is shutdown or not, if shutdown rm the service and then start
# 		# otherwise it may give duplicate service error (possible)
# 		echo "Microservices Viewer Weave Scope Web UI service is not running, check if the service is shutdown"
# 		docker service ps -f "desired-state=shutdown" "$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME" > /dev/null 2>&1
# 		if [ $? -eq 0 ];
# 		then
# 			# service is shutdown and hence exists, remove servcie and recreate
# 			echo "Microservices Viewer Weave Scope Web UI service already present in shutdown state, removing and creating new one..."
# 			echo "Removing the service now.."
# 			docker service rm "$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME"
# 			echo "Microservices Viewer Weave Scope Web UI service removed successfully, creating new one..."
			
# 		else
# 			# service is not present
# 			echo "Microservices Viewer Weave Scope Web UI service is not  present or not in shutdown state, hence creating new one.."
# 		fi
# 		# now start the service
# 		docker-machine ssh "${CLUSTER_NAMES[$i]}-${ENVIRONMENT}-0$((i+1))" 'sudo curl -L git.io/scope -o /usr/local/bin/scope; \
# 		sudo chmod a+x /usr/local/bin/scope; \
# 		scope launch'
# 	fi
# 	echo "node processed succesfully"
# done



# start the microservices viewer web ui service weave scope in the swarm manager node
echo "Starting Microservices Viewer Web Ui Weave Scope..."

# first check if the service is already running or not
# if running then move on, otherwise create the service
echo "First, checking if service is already running or not..."
docker service ps -f "desired-state=running" "$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME" > /dev/null 2>&1
if [ $? -eq 0 ];
then
	# service is already running
	echo "Microservices Viewer Weave Scope Web UI service already running, moving forward"
else
	# check if service is shutdown or not, if shutdown rm the service and then start
	# otherwise it may give duplicate service error (possible)
	echo "Microservices Viewer Weave Scope Web UI service is not running, check if the service is shutdown"
	docker service ps -f "desired-state=shutdown" "$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME" > /dev/null 2>&1
	if [ $? -eq 0 ];
	then
		# service is shutdown and hence exists, remove servcie and recreate
		echo "Microservices Viewer Weave Scope Web UI service already present in shutdown state, removing and creating new one..."
		echo "Removing the service now.."
		docker service rm "$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME"
		echo "Microservices Viewer Weave Scope Web UI service removed successfully, creating new one..."
		
	else
		# service is not present
		echo "Microservices Viewer Weave Scope Web UI service is not  present or not in shutdown state, hence creating new one.."
	fi
	# now start the service
	# echo "first pulling image"
	# docker pull lmarsden/scope-runner
	# echo "image pulled successfully"
	echo "creating service from image"
	docker service create \
		--name="$MICROSERVICES_VIEWER_WEAVE_SCOPE_WEB_UI_SERVICE_NAME" \
		--mode=global \
		--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
		lmarsden/scope-runner scope launch
fi

echo "Microservices Viewer Weave Scope Web UI started successfully"
	