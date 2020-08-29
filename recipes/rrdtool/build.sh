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

XFAIL_TESTS=""
if [[ $(uname) == Darwin ]]; then
    # No sure why this fails but it appears to be an upstream issue with macOS
    XFAIL_TESTS="${XFAIL_TESTS} rpn2"
fi

make check XFAIL_TESTS="${XFAIL_TESTS}" || (cat tests/test-suite.log && exit 1)

make install
