#!/bin/bash

source $ENV_INIT_SCRIPT_PATH/.env
echo "Environment : $ENVIRONMENT"

source $ENV_PATH/$ENVIRONMENT/cluster-node-names
source $ENV_PATH/$ENVIRONMENT/.env

if [ "$ENVIRONMENT" == "dev" ]; then
	echo "Dev Provisioning Tool : $DEV_PROVISIONING_TOOL_DRIVER"
	
	
	source $ENV_PATH/$ENVIRONMENT/$DEV_PROVISIONING_TOOL_DRIVER/.env
else
	echo "Cloud Provider : $CLOUD_PROVIDER"
	echo "Provisioning Tool : $PROVISIONING_TOOL"

	source $ENV_PATH/$ENVIRONMENT/$CLOUD_PROVIDER/$PROVISIONING_TOOL/.env
fi



echo "Cluser Size: $CLUSTER_SIZE"
echo "Manager Nodes : $MANAGER_COUNT"
echo "WORKER Nodes : $WORKER_COUNT"


