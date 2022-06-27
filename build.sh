#!/bin/bash

IS_LATEST=true
DEBIAN_REL=bullseye
BIND_VER=9.19.2

docker build -t smbd/dig:${BIND_VER} --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .

if "${IS_LATEST}" == true ; then
  docker build -t smbd/dig:latest --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .
fi
