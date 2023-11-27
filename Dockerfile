# inspired by https://github.com/hauptmedia/docker-jmeter  and
# https://github.com/hhcordero/docker-jmeter-server/blob/master/Dockerfile
FROM alpine:3.18

ARG JMETER_VERSION="5.6"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_CUSTOM_PLUGINS_FOLDER /plugins
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_CERTIFICATES=""

# Install extra packages
# Set TimeZone, See: https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-612751142
ARG TZ="Europe/Amsterdam"
ENV TZ ${TZ}
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
# pre-load plugins
	&& curl -L --silent https://jmeter-plugins.org/files/packages/bzm-random-csv-0.8.zip > /tmp/dependencies/bzm-random-csv.zip \
	&& unzip -oq /tmp/dependencies/bzm-random-csv.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-autostop-0.2.zip > /tmp/dependencies/jpgc-autostop.zip \
	&& unzip -oq /tmp/dependencies/jpgc-autostop.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/bzm-parallel-0.11.zip > /tmp/dependencies/bzm-parallel.zip \
	&& unzip -oq /tmp/dependencies/bzm-parallel.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-filterresults-2.2.zip > /tmp/dependencies/jpgc-filterresults.zip \
	&& unzip -oq /tmp/dependencies/jpgc-filterresults.zip -d ${JMETER_HOME} \
# cleanup
	&& rm -rf /tmp/dependencies

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Entrypoint has same signature as "jmeter" command
COPY entrypoint.sh /

WORKDIR	${JMETER_HOME}

RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
