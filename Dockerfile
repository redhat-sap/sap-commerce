FROM registry.redhat.io/ubi8/ubi:8.1

LABEL io.openshift.s2i.destination="/tmp"  \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      maintainer="Red Hat SAP Community of Practice"

ENV SAPMACHINE_FILE_NAME='sapmachine-jdk-11.0.5-1.x86_64.rpm' \
    HYBRIS_FILE_NAME='hybris.tar.gz' \
    HYBRIS_HOME='/opt/hybris' \
    STAGING_DIR='/tmp/staging'

RUN INSTALL_PKGS="gettext procps-ng tar zip unzip hostname net-tools lsof" && \
   yum install -y $INSTALL_PKGS && \
   rpm -V $INSTALL_PKGS && \
   yum clean all

RUN mkdir -p $STAGING_DIR && \
    curl -u $NEXUS_USER:$NEXUS_PASSWORD -v -k -o $STAGING_DIR/$HYBRIS_FILE_NAME  $NEXUS_URL/repository/$NEXUS_REPO/$HYBRIS_FILE_NAME && \
    curl -u $NEXUS_USER:$NEXUS_PASSWORD -v -k -o $STAGING_DIR/$SAPMACHINE_FILE_NAME  $NEXUS_URL/repository/$NEXUS_REPO/$SAPMACHINE_FILE_NAME && \
    mkdir -p /opt/hybris  && \
    /usr/bin/tar -xvzf $STAGING_DIR/$HYBRIS_FILE_NAME -C /opt && \
    yum install -y $STAGING_DIR/$SAPMACHINE_FILE_NAME && \
    rm -rf $STAGING_DIR && \
    cp -R $HYBRIS_HOME/bin/platform/resources/configtemplates/production $HYBRIS_HOME/config && \
    useradd -u 1001 -r -g 0 -d /opt/hybris -s /sbin/nologin -c "Hybris User" hybris && \
    chmod -R g+rwX /opt/hybris && \
    chown -R 1001:root /opt/hybris

COPY s2i /usr/local/s2i

RUN chmod -R u+rwx /usr/local/s2i && \
    chmod -R g+rwx /usr/local/s2i && \
    chown -R 1001:root /usr/local/s2i

EXPOSE 9001
EXPOSE 9002

USER 1001