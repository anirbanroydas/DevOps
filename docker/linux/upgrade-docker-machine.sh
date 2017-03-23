#!/bin/bash

DOCKER_MACHINE_VERSION=v0.10.0

curl -L https://github.com/docker/machine/releases/download/"$DOCKER_MACHINE_VERSION"/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
  chmod +x /usr/local/bin/docker-machine

