#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

./configure \
    "--prefix=${PREFIX}" \
    --disable-static \
    "--with-sasl2=${PREFIX}" \
    "--with-kerberos5=${PREFIX}" \
    "--with-openldap=${PREFIX}" \
    "--with-voms=${PREFIX}" \
    LIBS='-ldl'

make "-j${CPU_COUNT}"

make check

make install
