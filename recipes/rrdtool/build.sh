#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

./configure \
    "--prefix=${PREFIX}" \
    "--with-systemdsystemunitdir=${PREFIX}/lib/systemd/system" \
    --disable-python \
    --disable-perl \
    --disable-ruby \
    --disable-lua \
    --disable-tcl \
    --disable-docs

make "-j${CPU_COUNT}"

make check || (cat tests/test-suite.log && exit 1)

make install
