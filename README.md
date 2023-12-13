Original Repository cloned from https://github.com/justb4/docker-jmeter
Patreon of original author: [![Patreon](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://patreon.com/justb4)
Inspiration for GUI-mode from https://github.com/guitarrapc/docker-jmeter-gui/tree/master

# container-jmeter

Container image for [Apache JMeter](http://jmeter.apache.org).
This Container image can be run as the ``jmeter`` command.

## Building

With the script [build.sh](build.sh) the container image can be build
from the [Dockerfile](Dockerfile) but this is not really necessary as
you may use your own ``podman build`` commandline.

See end of this doc for more detailed build/run/test instructions (thanks to @wilsonmar!)

### Build Options

Build arguments (see [build.sh](build.sh)) with default values if not passed to build:

- **JMETER_VERSION** - JMeter version, default ``5.4``. Use as env variable to build with another version: `export JMETER_VERSION=5.4`
- **IMAGE_TIMEZONE** - timezone of Container image, default ``"Europe/Amsterdam"``. Use as env variable to build with another timezone: `export IMAGE_TIMEZONE="Europe/Berlin"`

## Running

The Container image will accept the same parameters as ``jmeter`` itself, assuming
you run JMeter non-GUI with ``-n``.

There is a shorthand [run.sh](run.sh) command.
See [test.sh](test.sh) for an example of how to call [run.sh](run.sh).

## User Defined Variables

This is a standard facility of JMeter: settings in a JMX test script
may be defined symbolically and substituted at runtime via the commandline.
These are called JMeter User Defined Variables or UDVs.

See [test.sh](test.sh) and the [trivial test plan](tests/trivial/test-plan.jmx) for an example of UDVs passed to the Container
image via [run.sh](run.sh).

See also: https://www.novatec-gmbh.de/en/blog/how-to-pass-command-line-properties-to-a-jmeter-testplan/

## Adjust Java Memory Options

By default, JMeter reads out the available memory from the host machine and uses a fixed value of 80% of it as a maximum. If this causes Issues, there is the option to use environment variables to adjust the JVM memory Parameters:

```JVM_XMN``` to adjust maximum nursery size

```JVM_XMS``` to adjust initial heap size

```JVM_XMX``` to adjust maximum heap size

All three use values in Megabyte range.

## Installing JMeter plugins

To run the container with custom JMeter plugins installed you need to mount a volume /plugins with the .jar files. For example:
```sh
sudo podman run --name ${NAME} -i -v ${LOCAL_PLUGINS_FOLDER}:/plugins -v ${LOCAL_JMX_WORK_DIR}:${CONTAINER_JMX_WORK_DIR} -w ${PWD} ${IMAGE} $@
```

The ${LOCAL_PLUGINS_FOLDER} must have only .jar files. Folders and another file extensions will not be considered.

### Configuring the custom JMeter plugins folder location

It is also possible to define an alternate location to the custom JMeter plugins folder. Simply define a environment variable called `JMETER_CUSTOM_PLUGINS_FOLDER` with the desired folder path like in the example bellow:

```sh
sudo podman run --name ${NAME} -i -e JMETER_CUSTOM_PLUGINS_FOLDER=/jmeter/plugins -v ${LOCAL_PLUGINS_FOLDER}:/jmeter/plugins -v ${LOCAL_JMX_WORK_DIR}:${CONTAINER_JMX_WORK_DIR} -w ${PWD} ${IMAGE} $@
```


## Do it for real: detailed build/run/test

Contribution by @wilsonmar

1. In a Terminal/Command session, install Git, navigate/make a folder, then:

   ```
   git clone https://github.com/RISE-GmbH/container-jmeter
   cd container-jmeter
   ```

1. Run the Build script to download dependencies:

   ```
   ./build.sh
   ```

   If you view this file, the <strong>podman build</strong> command within the script is for a specific version of JMeter and implements the <strong>Dockerfile</strong> in the same folder.

   If you view the Dockerfile, notice the `JMETER_VERSION` specified is the same as the one in the build.sh script. The FROM keyword specifies the Alpine operating system, which is very small (less of an attack surface). Also, no JMeter plug-ins are used.

   At the bottom of the Dockerfile is the <strong>entrypoint.sh</strong> file. If you view it, that's where JVM memory settings are specified for <strong>jmeter</strong> before it is invoked. PROTIP: Such settings need to be adjusted for tests of more complexity.

   The last line in the response should be:

   <tt>Successfully tagged rise/jmeter:5.6</tt>

1. Run the test script:

   ```
   ./test.sh
   ```

   If you view the script, note it invokes the <strong>run.sh</strong> script file stored at the repo's root. View that file to see that it specifies container image commands.

   File and folder names specified in the test.sh script is reflected in the last line in the response for its run:

   <pre>
   ==== HTML Test Report ====
   See HTML test report in tests/trivial/report/index.html
   </pre>

   *Alternative exec by Makefile:*

   Like the bash script, it is possible to run the tests through a **Makefile** simply with the `make` command or by sending parameters as follows:

   ```sh
   TARGET_HOST="www.map5.nl" \
   TARGET_PORT="80" \
   THREADS=10 \
   TEST=trivial \
   make
   ```

1. Switch to your machine's Folder program and navigate to the folder containing files which replaces files cloned in from GitHub:

   ```
   cd tests/trivial
   ```

   The files are:

   * jmeter.log
   * reports folder (see below)
   * test-plan.jmx containing the JMeter test plan.
   * test-plan.jtl containing statistics from the run displayed by the index.html file.


1. Navigate into the <strong>report</strong> folder and open the <strong>index.html</strong> file to pop up a browser window displaying the run report:

   ```
   cd report
   open index.html
   ```

## Certificates

If you need jMeter to be aware of specific certificates, these can be specified by their full path by the environment variable `JMETER_CERTIFICATES`. Multiple certificates can be specified by separating their path with a comma. The format of the certificates needs to be ".p12". A passphrase is specified by the string after the filepath separated by a colon.

Example:

```
/tmp/certificate1.p12:passphrase123,/tmp/certificate2.p12:passphrase456
```

In a call this would look like this:

```
podman run --rm --name jmeter -e JMETER_CERTIFICATES='/tmp/certificate1.p12:passphrase123,/tmp/certificate2.p12:passphrase456' ...
```

Beware that the certificates path provided must be accessible from within the image - that means, you have to make sure that locally stored certificates are mounted in the container at the appropriate location at runtime.

## Specifics

The Container image built from the
[Dockerfile](Dockerfile) inherits from the [Alpine Linux](https://www.alpinelinux.org) distribution:

> "Alpine Linux is built around musl libc and busybox. This makes it smaller
> and more resource efficient than traditional GNU/Linux distributions.
> A container requires no more than 8 MB and a minimal installation to disk
> requires around 130 MB of storage.
> Not only do you get a fully-fledged Linux environment but a large selection of packages from the repository."

See https://hub.docker.com/_/alpine/ for Alpine Docker images.

The Container image will install (via Alpine ``apk``) several required packages most specificly
the ``OpenJDK Java JRE``.  JMeter is installed by simply downloading/unpacking a ``.tgz`` archive
from http://mirror.serversupportforum.de/apache/jmeter/binaries within the Container image.

A generic [entrypoint.sh](entrypoint.sh) is copied into the Container image and
will be the script that is run when the container is run. The
[entrypoint.sh](entrypoint.sh) simply calls ``jmeter`` passing all argumets provided
to the container, see [run.sh](run.sh) script:

```
sudo podman run --name ${NAME} -i -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR} ${IMAGE} $@
```

## Credits

Thanks to https://github.com/hauptmedia/docker-jmeter
and https://github.com/hhcordero/docker-jmeter-server for providing
the Dockerfiles that inspired me.   @wilsonmar for contributing detailed instructions. Others
that tested/reported after version updates.
https://github.com/justb4/docker-jmeter was the original source repo
Inspiration for adding GUI-mode with VNC server from https://github.com/guitarrapc/docker-jmeter-gui/tree/master
