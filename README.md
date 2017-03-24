# DevOps
All DevOps related scripts, resources and configurations

## Details

- Author: Anirban Roy Das
- Email: anirban.nick@gmail.com
- Copyright(C): 2016, Anirban Roy Das <anirban.nick@gmail.com>

Check `DevOps/LICENSE` file for full Copyright notice.


## Supported Platforms

- MacOs (primarily)
- Linux

## Things to Note

This project has all the devops related tools, resources, scripts which you can use to start of your work in both dev and close-to-production environments

Whenever you are concerened with a particular devops scenario, like say monitoring, then focus only on the monitoring root level directory and the environments directory according to your environment (dev, prod, staging, etc) and for production, look into your production cloud provider IAAS (aws, gcp, azure, etc).

So basically root level environmets directory may be used in all the devops operations along with the root level directory pertaining to your requirement, like monitoring, logging, ci-cd, etc.

## Usage

- First setup your environment. Go to ` setup ` root level directory inside the project and follow the instructions there or run any script if present according to your dev environment (**Linux** or **MacOS**).

- If you just want to **update** your **docker** tools, then go to ` docker ` folder and run the appropriate upgrade script according to your environment.

- Then if you don't already have a dev environment (docker machine, docker engines, vms) ready on which you will work your docker commands then go ahead provision them. Go to ` provisioning ` directory and run the appropriate scripts according to your environment (dev, prod, staging etc.) and appropriate IAAS cloud provider (aws, azure, gcp etc).

- If you want to follow some reference to few things, then checkout the ` linux-ops ` directory.

- Wherever you see a ` env ` file, do the following:
    1. Copy(not move) it as ` .env `
    2. Change the environment variables in the ` .env ` file according to your usage

- Inside the ` storage-provisioning/rex-ray ` directory, wherever you see a ` config.yml ` file, do the following:
    1. Copy(no move) it as ` .config.yml `
    2. Update the ` .config.yml ` file's contents according to your requirement

## Infrastructure Provisioning Tools

- Docker
- Terraform + Packer
- Docker Machine

## Configuration Management and Provisioning Tools

- Docker Compose
- Terraform

## Continuous Integration Tools

- Jenkins
- Travis CI


## Logs Monitoring Tools (in a docker environment setup)

- ELK stack
    - Elasticsearch
    - Logstash
    - Kibana
- EFK stack
    - Elasticsearch
    - Fluentd
    - Kibana

## Metrics Monitoring Tools (in a docker environment setup)

- Prometheus + Grafana
- cAdvisor + InfluxDB + Grafana

## Load Balancing

- Nginx
- HAProxy

## Persistant Storage Provisioning and Management (in a docker environment setup)

- RexRay
- Flocker
- ScaleIO

## Web UI Management 

- Swarm Viewer (manomarks/visualizer)
- Weavescope
- Portainer
- Rancher

## Cluster Orchestration Tools

- Docker Swarm Mode
- Kubernetes
