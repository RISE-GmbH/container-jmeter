#!/bin/bash
#
# Run JMeter Container image with options

NAME="jmeter"
JMETER_VERSION=${JMETER_VERSION:-"latest"}
IMAGE="rise/jmeter:${JMETER_VERSION}"

# Finally run
podman run --rm --name ${NAME} -i -v ${PWD}:${PWD} -w ${PWD} ${IMAGE} $@
