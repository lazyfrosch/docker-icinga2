#!/bin/bash

set -e

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT

# Downloading current Packages
curl -LsS -o "${tmp}" https://packages.icinga.com/ubuntu/dists/icinga-bionic-snapshots/main/binary-amd64/Packages

# Searching for latest icinga2 package
awk '/^Package: icinga2$/ { f=1; next }; f && /^Version: / { print $2; f=0 }' "${tmp}" | sort | tail -n1
