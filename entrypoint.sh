#!/bin/bash
# Inspired from https://github.com/hhcordero/docker-jmeter-client
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standdard JMeter command parameters.
#

# Install jmeter plugins available on /plugins volume
if [ -d $JMETER_CUSTOM_PLUGINS_FOLDER ]
then
    for plugin in ${JMETER_CUSTOM_PLUGINS_FOLDER}/*.jar; do
        cp $plugin ${JMETER_HOME}/lib/ext
    done;
fi

# prepare provided certificates and generate certificate file
if [ ! -z "$JMETER_CERTIFICATES" ]
then
    for CERT in ${JMETER_CERTIFICATES//,/ }
    do
        CERTPATH=$(echo ${CERT} | cut -s -d':' -f1)
        CERTPASS=$(echo ${CERT} | cut -s -d':' -f2)
        if [ -z "$CERTPATH" ]
        then
            CERTPATH=${CERT}
        fi
        echo preparing certificate file "'$CERTPATH'"
#        echo CERTPATH="$CERTPATH"
#        echo CERTPASS="$CERTPASS"
        keytool -importkeystore -srckeystore ${CERTPATH} -srcstoretype PKCS12 -storepass lenserjmeter -srcstorepass ${CERTPASS} -destkeystore ${JMETER_HOME}/keystore.jks -deststoretype JKS -destkeypass "lenserjmeter" -deststorepass "lenserjmeter" -noprompt
    done
else
    # create a pseudo-keystore to facilitate the setting up of the keystor config in jMeter
    echo generating dummy keystore
    keytool -genkeypair -alias placeholder -storepass lenserjmeter -keypass lenserjmeter -keystore ${JMETER_HOME}/keystore.jks -deststoretype JKS -destkeypass "lenserjmeter" -dname "CN=RISE, OU=COMPRISE, O=LENSER, L=Vienna, ST=Vienna, C=CA" -noprompt
fi

# modify jMeter system.properties config file to include the generated keystore
echo "javax.net.ssl.keyStoreType=JKS" >> ${JMETER_HOME}/bin/system.properties
echo "javax.net.ssl.keyStore=${JMETER_HOME}/keystore.jks" >> ${JMETER_HOME}/bin/system.properties
echo "javax.net.ssl.keyStorePassword=lenserjmeter" >> ${JMETER_HOME}/bin/system.properties

echo "https.use.cached.ssl.context=false" >> ${JMETER_HOME}/bin/user.properties

# Execute JMeter command
set -e
freeMem=`awk '/MemAvailable/ { print int($2/1024) }' /proc/meminfo`

[[ -z ${JVM_XMN} ]] && JVM_XMN=$(($freeMem/10*2))
[[ -z ${JVM_XMS} ]] && JVM_XMS=$(($freeMem/10*8))
[[ -z ${JVM_XMX} ]] && JVM_XMX=$(($freeMem/10*8))

export JVM_ARGS="-Xmn${JVM_XMN}m -Xms${JVM_XMS}m -Xmx${JVM_XMX}m"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

# Keep entrypoint simple: we must pass the standard JMeter arguments
EXTRA_ARGS=-Dlog4j2.formatMsgNoLookups=true
echo "jmeter ALL ARGS=${EXTRA_ARGS} $@"
jmeter ${EXTRA_ARGS} $@

echo "END Running Jmeter on `date`"

#     -n \
#    -t "/tests/${TEST_DIR}/${TEST_PLAN}.jmx" \
#    -l "/tests/${TEST_DIR}/${TEST_PLAN}.jtl"
# exec tail -f jmeter.log
#    -D "java.rmi.server.hostname=${IP}" \
#    -D "client.rmi.localport=${RMI_PORT}" \
#  -R $REMOTE_HOSTS
