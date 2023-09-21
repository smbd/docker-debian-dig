#!/bin/bash

DEBIAN_REL="bullseye"

while getopts lp OPT ; do
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

# delete old debian base image
docker rmi debian:${DEBIAN_REL}-slim

BIND_VER="$1"

if [ "${PUSH}" == "true" ] ; then
  docker buildx build --progress=plain --push --platform linux/amd64,linux/arm64 -t smbd/dig:${BIND_VER} --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .

  if [ "${LATEST}" == "true" ] ; then
    docker buildx build --push --platform linux/amd64,linux/arm64 -t smbd/dig:latest --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .
  fi
fi

docker buildx build --progress=plain --load -t smbd/dig:${BIND_VER} --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .
if [ "${LATEST}" == "true" ] ; then
  docker buildx build --progress=plain --load -t smbd/dig:latest --build-arg DEBIAN_REL=${DEBIAN_REL} --build-arg BIND_VER=${BIND_VER} .
fi
