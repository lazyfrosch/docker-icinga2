FROM ubuntu:bionic

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y curl wget gnupg2 \
 && rm -rf /var/lib/apt/lists/*

ENV ICINGA2_VERSION=2.10.4

RUN curl -LsS https://packages.icinga.com/icinga.key | apt-key add - \
 && echo "deb http://packages.icinga.com/ubuntu icinga-bionic main" >/etc/apt/sources.list.d/icinga.list \
 && apt-get update \
 && I2VER="${ICINGA2_VERSION}-1.bionic" DEBIAN_FRONTEND=noninteractive bash -c \
    'apt-get install -y --no-install-recommends icinga2{,-bin,-common,-ido-mysql}="${I2VER}" monitoring-plugins' \
 && apt-get install -y fakeroot default-mysql-client netcat-openbsd \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/icinga2/conf.d/* \
 && rm -rf /etc/icinga2/zones.d/* \
 && chown -R nagios.nagios /etc/icinga2 \
 && mkdir /run/icinga2 \
 && chown nagios.nagios /run/icinga2

# TODO: remove when added to changelog
RUN gzip -d /usr/share/doc/icinga2/changelog.Debian.gz \
 && sed -i 's/Update to 2.8.4/\0 (CVE-2017-16933)/' /usr/share/doc/icinga2/changelog.Debian \
 && gzip /usr/share/doc/icinga2/changelog.Debian

VOLUME /var/lib/icinga2
VOLUME /var/log/icinga2

COPY root/ /

USER nagios
ENTRYPOINT ["docker-entrypoint"]

EXPOSE 5665
CMD ["icinga2-foreground"]
