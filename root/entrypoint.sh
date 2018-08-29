#!/bin/bash

ICINGA2_CONFDIR=/etc/icinga2
ICINGA2_DATADIR=/var/lib/icinga2
ICINGA2_USER=nagios
ICINGA2_GROUP=nagios

ensure_icinga_dir() {
  if [ ! -d "$1" ]; then
    echo "Creating directory $1"
    mkdir "$1"
  fi
  if [ "$(stat -c%U "$1")" = "root" ]; then
    echo "Updating owner of $1"
    chown "${ICINGA2_USER}.${ICINGA2_GROUP}" "$1"
  fi
}

ensure_icinga_dir "${ICINGA2_CONFDIR}/zones.d"
ensure_icinga_dir "${ICINGA2_DATADIR}/api"
ensure_icinga_dir "${ICINGA2_DATADIR}/certs"

exec "$@"
