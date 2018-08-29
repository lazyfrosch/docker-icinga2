FROM ubuntu:xenial

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y curl wget \
 && rm -rf /var/lib/apt/lists/*

ENV ICINGA2_VERSION=2.9.1

RUN curl -LsS https://packages.icinga.com/icinga.key | apt-key add - \
 && echo "deb http://packages.icinga.com/ubuntu icinga-xenial main" >/etc/apt/sources.list.d/icinga.list \
 && apt-get update \
 && I2VER="${ICINGA2_VERSION}-1.xenial" bash -c \
    'apt-get install -y --no-install-recommends icinga2{,-bin,-common}="${I2VER}" libicinga2="${I2VER}"' \
 && rm -rf /etc/icinga2/conf.d/* \
 && rm -rf /etc/icinga2/zones.d/* \
 && rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/icinga2

COPY root/ /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 5665
CMD ["icinga2-foreground"]
