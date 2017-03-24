#!/bin/bash

source .env
echo "Environment : $ENVIRONMENT"
echo "Provisioning Tool : $PROVISIONING_TOOL"

source $ENV_PATH/$ENVIRONMENT/.env
source $ENV_PATH/$ENVIRONMENT/cluster-node-names

source $ENV_PATH/$ENVIRONMENT/$PROVISIONING_TOOL/.env

export STORAGE_PROVISION_CONFIG_FILE="$STORAGE_PROVISION_PATH/$STORAGE_PROVISIONING_TOOL/$ENVIRONMENT/$PROVISIONING_TOOL/.config.yml"


echo "Cluser Size: $CLUSTER_SIZE"

echo "Manager Count: $MANAGER_COUNT"
echo "Worker Count: $WORKER_COUNT"

echo "Storage Provisioning Config File : $STORAGE_PROVISION_CONFIG_FILE"


