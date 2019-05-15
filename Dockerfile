FROM ubuntu:bionic

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y curl wget gnupg2 \
 && rm -rf /var/lib/apt/lists/*

# at least this version - not used but will invalidate cache
ARG ICINGA2_VERSION=2.10.4+695.0

RUN curl -LsS https://packages.icinga.com/icinga.key | apt-key add - \
 && echo "deb http://packages.icinga.com/ubuntu icinga-bionic main" >/etc/apt/sources.list.d/icinga.list \
 && echo "deb http://packages.icinga.com/ubuntu icinga-bionic-snapshots main" >>/etc/apt/sources.list.d/icinga.list \
 && apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y --no-install-recommends monitoring-plugins \
 && bash -c 'apt-get install -y --no-install-recommends -t icinga-bionic-snapshots icinga2{,-bin,-common,-ido-mysql}' \
 && dpkg -l "icinga*" \
 && apt-get install -y --no-install-recommends fakeroot default-mysql-client netcat-openbsd \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/icinga2/conf.d/* \
 && rm -rf /etc/icinga2/zones.d/* \
 && chown -R nagios.nagios /etc/icinga2 \
 && mkdir /run/icinga2 \
 && chown nagios.nagios /run/icinga2

VOLUME /var/lib/icinga2
VOLUME /var/log/icinga2

COPY root/ /

USER nagios
ENTRYPOINT ["docker-entrypoint"]

EXPOSE 5665
CMD ["icinga2-foreground"]
