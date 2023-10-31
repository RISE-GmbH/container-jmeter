#!/bin/bash

JMETER_VERSION=${JMETER_VERSION:-"5.6"}
IMAGE_TIMEZONE=${IMAGE_TIMEZONE:-"Europe/Amsterdam"}

# Example build line
docker build  --build-arg JMETER_VERSION=${JMETER_VERSION} --build-arg TZ=${IMAGE_TIMEZONE} -t "rise/jmeter:${JMETER_VERSION}" .
