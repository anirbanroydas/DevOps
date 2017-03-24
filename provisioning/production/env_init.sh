#!/bin/bash

source $ENV_INIT_SCRIPT_PATH/.env
echo "Environment : $ENVIRONMENT"
echo "Cloud Provider : $CLOUD_PROVIDER"
echo "Provisioning Tool : $PROVISIONING_TOOL"

source $ENV_PATH/$ENVIRONMENT/.env
source $ENV_PATH/$ENVIRONMENT/$CLOUD_PROVIDER/$PROVISIONING_TOOL/.env

export STORAGE_PROVISION_CONFIG_FILE="$STORAGE_PROVISION_PATH/$STORAGE_PROVISIONING_TOOL/$ENVIRONMENT/$CLOUD_PROVIDER/.config.yml"


echo "Cluser Size: $CLUSTER_SIZE"

echo "Manager Count: $MANAGER_COUNT"
echo "Worker Count: $WORKER_COUNT"
echo "Storage provisioning config file: $STORAGE_PROVISION_CONFIG_FILE"


# source $ENV_PATH/$ENVIRONMENT/cluster-node-names
source $ENV_PATH/$ENVIRONMENT/open_ports
