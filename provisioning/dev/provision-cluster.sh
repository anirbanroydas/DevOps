#!/bin/bash

set -ev

CLUSTER_SIZE=3

# create a docker swarm cluster of 3 nodes - 1 master and  2 worker
docker-machine create --driver virtualbox johnsnow-manager-dev-01
sleep 2

# create the rest of the worker nodes
docker-machine create --driver virtualbox lannisters-worker-dev-02
sleep 2
docker-machine create --driver virtualbox starks-worker-dev-03
sleep 2

# list the cluster machines
docker-machine ls

# change docker machine env to swarm manager
eval $(docker-machine env johnsnow-manager-dev-01)

# check active machine status again
echo "Active Machine : $(docker-machine active)"

MANAGER_IP=`docker-machine ip johnsnow-manager-dev-01`
echo "Swarm Manager IP : ${MANAGER_IP}"

# initialize swarm mode
docker swarm init --advertise-addr ${MANAGER_IP}
sleep 2

# save the swarm token to use in the rest of the nodes
SWARM_WORKER_JOIN_TOKEN=$(docker swarm join-token -q worker)

# initialize the worker to join the swarm
eval $(docker-machine env lannisters-worker-dev-02)
echo "Active Machine : $(docker-machine active)"
docker swarm join --token ${SWARM_WORKER_JOIN_TOKEN} ${MANAGER_IP}:2377
sleep 2

eval $(docker-machine env starks-worker-dev-03)
echo "Active Machien : $(docker-machine active)"
docker swarm join --token ${SWARM_WORKER_JOIN_TOKEN} ${MANAGER_IP}:2377
sleep 2

# make swarm manager active again
eval $(docker-machine env johnsnow-manager-dev-01)
echo "Active Machine : $(docker-machine active)"
docker node ls

echo "Provisioning Successful"



