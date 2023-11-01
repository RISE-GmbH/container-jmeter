#!/bin/bash
#
# Run JMeter Container image with options

NAME="jmeter"
JMETER_VERSION=${JMETER_VERSION:-"latest"}
IMAGE_PREFIX="rise"
IMAGE="${IMAGE_PREFIX}/jmeter:${JMETER_VERSION}"

# Finally run
echo "podman run --rm --name ${NAME} -i -v ${PWD}:${PWD} -w ${PWD} ${IMAGE} $@"
podman run --rm --name ${NAME} -i -v ${PWD}:${PWD} -w ${PWD} ${IMAGE} $@
