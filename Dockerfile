FROM ubuntu:jammy

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y curl gnupg2 \
 && rm -rf /var/lib/apt/lists/*

# renovate: datasource=github-releases depName=Icinga/icinga2
ENV ICINGA2_VERSION=2.13.6
ENV ICINGA2_PACKAGE_VERSION=${ICINGA2_VERSION}-1
ENV UID=101
ENV GID=101

RUN groupadd -g ${GID} nagios \
 && useradd -g ${GID} -u ${UID} -m -d /var/lib/nagios -s /bin/false nagios

RUN curl -LsS https://packages.icinga.com/icinga.key | gpg --dearmor >/etc/apt/trusted.gpg.d/icinga.gpg - \
 && . /etc/os-release \
 && echo "deb http://packages.icinga.com/ubuntu icinga-${VERSION_CODENAME} main" >/etc/apt/sources.list.d/icinga.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive bash -c \
    "apt-get install -y --no-install-recommends icinga2{,-bin,-common,-ido-mysql}='${ICINGA2_PACKAGE_VERSION}.${VERSION_CODENAME}' monitoring-plugins" \
 && apt-get install -y --no-install-recommends fakeroot default-mysql-client netcat-openbsd \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/icinga2/conf.d/* \
 && rm -rf /etc/icinga2/zones.d/* \
 && chown -R nagios.nagios /etc/icinga2 \
 && mkdir /run/icinga2 \
 && chown nagios.nagios /run/icinga2 \
 && mkdir /var/lib/icinga2/ca \
 && chown nagios.nagios /var/lib/icinga2/ca

VOLUME /var/lib/icinga2

COPY root/ /

USER nagios
ENTRYPOINT ["docker-entrypoint"]

EXPOSE 5665
CMD ["icinga2-foreground"]
