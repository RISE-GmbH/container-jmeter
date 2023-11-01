#!/bin/bash

JMETER_VERSION=${JMETER_VERSION:-"5.6.2"}
IMAGE_TIMEZONE=${IMAGE_TIMEZONE:-"Europe/Amsterdam"}
IMAGE_PREFIX=rise

# Example build line
podman build  --build-arg JMETER_VERSION=${JMETER_VERSION} --build-arg TZ=${IMAGE_TIMEZONE} -t "${IMAGE_PREFIX}/jmeter:${JMETER_VERSION}" .
podman tag "${IMAGE_PREFIX}/jmeter:${JMETER_VERSION}" "${IMAGE_PREFIX}/jmeter:latest"

podman image save --format docker-archive ${IMAGE_PREFIX}/jmeter:${JMETER_VERSION} | gzip > ${IMAGE_PREFIX}_jmeter_${JMETER_VERSION}.tar.gz
