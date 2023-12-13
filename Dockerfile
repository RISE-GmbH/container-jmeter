# inspired by https://github.com/hauptmedia/docker-jmeter and
# https://github.com/hhcordero/docker-jmeter-server/blob/master/Dockerfile and
# https://github.com/guitarrapc/docker-jmeter-gui/tree/master
FROM alpine:3.18

ARG JMETER_VERSION="5.6"
# Set TimeZone, See: https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-612751142
ARG TZ="Europe/Amsterdam"
ENV TZ=${TZ}
ENV JMETER_HOME=/opt/apache-jmeter
ENV JMETER_CUSTOM_PLUGINS_FOLDER=/plugins
ENV JMETER_BIN=${JMETER_HOME}/bin
ENV JMETER_DOWNLOAD_URL=https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_CERTIFICATES=""
ENV PATH=$PATH:$JMETER_BIN
ENV DISPLAY=":99"
ENV RESOLUTION="1366x768x24"
ENV PASS="root"

STOPSIGNAL SIGKILL

# Install extra packages
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk17-jre tzdata curl unzip bash xfce4-terminal xvfb x11vnc xfce4 tini \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& mv /opt/apache-jmeter-${JMETER_VERSION} ${JMETER_HOME} \
    && x11vnc -storepasswd ${PASS} /etc/x11vnc.pass \
# pre-load plugins
	&& curl -L --silent https://jmeter-plugins.org/files/packages/bzm-random-csv-0.8.zip > /tmp/dependencies/bzm-random-csv.zip \
	&& unzip -oq /tmp/dependencies/bzm-random-csv.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-autostop-0.2.zip > /tmp/dependencies/jpgc-autostop.zip \
	&& unzip -oq /tmp/dependencies/jpgc-autostop.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/bzm-parallel-0.11.zip > /tmp/dependencies/bzm-parallel.zip \
	&& unzip -oq /tmp/dependencies/bzm-parallel.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-filterresults-2.2.zip > /tmp/dependencies/jpgc-filterresults.zip \
	&& unzip -oq /tmp/dependencies/jpgc-filterresults.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-casutg-2.10.zip > /tmp/dependencies/jpgc-casutg.zip \
	&& unzip -oq /tmp/dependencies/jpgc-casutg.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-tst-2.6.zip > /tmp/dependencies/jpgc-tst.zip \
	&& unzip -oq /tmp/dependencies/jpgc-tst.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-wsc-0.7.zip > /tmp/dependencies/jpgc-wsc.zip \
	&& unzip -oq /tmp/dependencies/jpgc-wsc.zip -d ${JMETER_HOME} \
	&& curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-dummy-0.4.zip > /tmp/dependencies/jpgc-dummy.zip \
	&& unzip -oq /tmp/dependencies/jpgc-dummy.zip -d ${JMETER_HOME} \
# cleanup
	&& rm -rf /tmp/dependencies

EXPOSE 5900

COPY entrypoint.sh /

WORKDIR /opt/lenser

ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
