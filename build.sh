#!/bin/bash

JMETER_VERSION=${JMETER_VERSION:-"5.6.2"}
IMAGE_TIMEZONE=${IMAGE_TIMEZONE:-"Europe/Amsterdam"}

# Example build line
podman build  --build-arg JMETER_VERSION=${JMETER_VERSION} --build-arg TZ=${IMAGE_TIMEZONE} -t "rise/jmeter:${JMETER_VERSION}" .
podman tag "rise/jmeter:${JMETER_VERSION}" "rise/jmeter:latest"

podman image save --format docker-archive rise/jmeter:${JMETER_VERSION} | gzip > rise_jmeter_${JMETER_VERSION}.tar.gz
