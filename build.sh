#!/bin/bash

DEBIAN_REL="bullseye"

while getopts pt OPT ; do
  case ${OPT} in
    "l") LATEST="true" ;;
    "p") PUSH="true" ;;
  esac
done

shift $((${OPTIND}-1))

if [ "$1" == "" ] ; then
  echo "Usage: ${0} [-l] [-p] BIND_VERSION"
  echo "    -l: update latest tag"
  echo "    -p: push to dockerhub"
  exit 1
fi

BIND_VER="$1"

if [ "${PUSH}" == "true" ] ; then
  docker buildx build --push --platform linux/amd64,linux/arm64 -t smbd/dig:${BIND_VER} --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .

  if [ "${LATEST}" == "true" ] ; then
    docker buildx build --push --platform linux/amd64,linux/arm64 -t smbd/dig:latest --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .
  fi
else
  docker buildx build --load -t smbd/dig:${BIND_VER} --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .

  if [ "${LATEST}" == "true" ] ; then
    docker buildx build --load -t smbd/dig:latest --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .
  fi
fi
