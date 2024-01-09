# inspired by https://github.com/hauptmedia/docker-jmeter and
# https://github.com/hhcordero/docker-jmeter-server/blob/master/Dockerfile and
# https://github.com/guitarrapc/docker-jmeter-gui/tree/master
FROM alpine:3.18

ARG JMETER_VERSION="5.6.3"
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

COPY version_cleanup.py /version_cleanup.py

# Install extra packages
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk17-jre tzdata curl unzip bash xfce4-terminal xvfb x11vnc xfce4 tini mousepad \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} > /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz \
	&& mkdir -p /opt \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
	&& mv /opt/apache-jmeter-${JMETER_VERSION} ${JMETER_HOME} \
    && x11vnc -storepasswd ${PASS} /etc/x11vnc.pass \
	&& rm -rf /tmp/dependencies
# pre-load plugins
RUN    mkdir -p /tmp/dependencies \
    && curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/bzm-random-csv-0.8.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/jpgc-autostop-0.2.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/bzm-parallel-0.11.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/jpgc-filterresults-2.2.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/jpgc-casutg-2.10.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/jpgc-tst-2.6.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/jpgc-wsc-0.7.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/jpgc-dummy-0.4.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/jpgc-graphs-basic-2.0.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/jpgc-graphs-additional-2.0.zip \
	&& curl -L -O --silent --output-dir /tmp/dependencies https://jmeter-plugins.org/files/packages/extended-csv-dataset-config-2.0.zip \
	&& unzip -oq '/tmp/dependencies/*.zip' -d ${JMETER_HOME} \
    && curl -L -O --silent --output-dir ${JMETER_HOME}/lib/ext/ https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.10/jmeter-plugins-manager-1.10.jar \
 # cleanup
	&& rm -rf /tmp/dependencies \
    && python3 /version_cleanup.py /opt/apache-jmeter/lib \
    && python3 /version_cleanup.py /opt/apache-jmeter/lib/ext

EXPOSE 5900

COPY entrypoint.sh /

WORKDIR /opt/lenser

ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
