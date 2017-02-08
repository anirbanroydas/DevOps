#!/bin/bash

source .env
echo "Environment : $ENVIRONMENT"

source $ENV_PATH/$ENVIRONMENT/.env

[ -z "$CLUSTER_SIZE" ] &&  CLUSTER_SIZE=3
echo "Cluser Size: ${CLUSTER_SIZE}"

[ -z "$MANAGER_COUNT" ] && MANAGER_COUNT=1
[ -z "$WORKER_COUNT" ] && WORKER_COUNT=2


source $ENV_PATH/$ENVIRONMENT/cluster-node-names