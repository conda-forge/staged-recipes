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

# Fix hard coded paths in the tests
sed -i "s@/usr/bin/perl@${BUILD_PREFIX}/bin/perl@g" myproxy-test
sed -i 's@/bin/kill@kill@g' myproxy-test

# The tests assume this current directory is on PATH
PATH=$PWD:$PATH make check

make install
