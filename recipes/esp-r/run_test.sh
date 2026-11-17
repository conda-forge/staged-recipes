#!/bin/bash
set -euxo pipefail

# ESP-r stores file names in short fixed-length strings and cannot cope with
# the long prefix of the test environment: access it through a short link.
esp_short="$(mktemp -u /tmp/espr-XXXXXX)"
ln -s "${PREFIX}/opt/esp-r" "${esp_short}"
trap 'rm -f "${esp_short}"' EXIT
export ESPRDIR="${esp_short}"

# Weather file: binary -> ASCII export.
clm -mode text -file "${ESPRDIR}/climate/clm67" -act bin2asci silent clm67.a
test -s clm67.a

# Programs read their own path into a 72-character string: starting one
# through a longer path must not abort (patch 0003).
long_dir="$(printf 'd%.0s' $(seq 1 100))"
mkdir "${long_dir}"
ln -s "$(command -v clm)" "${long_dir}/clm"
"./${long_dir}/clm" -mode text -file "${ESPRDIR}/climate/clm67" \
  -act bin2asci silent clm67_long.a
test -s clm67_long.a

# Simulate a winter week of the basic training model and check that a
# results library is produced.
cp -r "${ESPRDIR}/training/basic" basic
cd basic/cfg
bps -file bld_basic.cfg -mode text -p win silent
test -s ../tmp/bld_basic_win.res
