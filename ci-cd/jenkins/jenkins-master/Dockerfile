FROM jenkins:2.32.2-alpine

USER root

RUN echo "http://dl-2.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk add --no-cache \
                ca-certificates \
                curl \
                openssl \
                sudo \
                shadow \
                python \
                py-pip \
                git \
                openssh \
                make \
                bash

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.13.1
ENV DOCKER_SHA256 97892375e756fd29a304bd8cd9ffb256c2e7c8fd759e12a55a6336e15100ad75
ENV DOCKER_COMPOSE_VERSION 1.11.1

RUN set -x \
        && curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
        && echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
        && tar -xzvf docker.tgz \
        && mv docker/* /usr/local/bin/ \
        && rmdir docker \
        && rm docker.tgz \
        && docker -v

RUN usermod -aG root jenkins
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# RUN chmod +x /usr/local/bin/docker-compose
RUN pip install docker-compose

# COPY docker-entrypoint.sh /usr/local/bin/

# RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir /var/log/jenkins
RUN mkdir /var/cache/jenkins
RUN chown -R  jenkins:jenkins /var/log/jenkins
RUN chown -R jenkins:jenkins /var/cache/jenkins

ENV JENKINS_OPTS="--logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war"

USER jenkins