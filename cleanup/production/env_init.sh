#!/bin/bash

source $ENV_INIT_SCRIPT_PATH/.env
echo "Environment : $ENVIRONMENT"
echo "Cloud Provider : $CLOUD_PROVIDER"
echo "Provisioning Tool : $PROVISIONING_TOOL"

source $ENV_PATH/$ENVIRONMENT/$CLOUD_PROVIDER/$PROVISIONING_TOOL/.env

[ -z "$CLUSTER_SIZE" ] &&  CLUSTER_SIZE=5
echo "Cluser Size: ${CLUSTER_SIZE}"

[ -z "$MANAGER_COUNT" ] && MANAGER_COUNT=3
[ -z "$WORKER_COUNT" ] && WORKER_COUNT=2


source $ENV_PATH/$ENVIRONMENT/cluster-node-names