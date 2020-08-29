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
if [[ "$(uname)" == "Darwin" && "${PKG_VERSION}" == "1.7.2" ]]; then
    # Known failure, should be fixed in the next version
    # https://github.com/oetiker/rrdtool-1.x/issues/1012
    XFAIL_TESTS="${XFAIL_TESTS} rpn2"
fi

make check XFAIL_TESTS="${XFAIL_TESTS}" || (cat tests/test-suite.log && exit 1)

make install
