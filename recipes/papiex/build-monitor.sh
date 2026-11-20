#!/bin/bash
set -euxo pipefail

cd monitor
cp "${BUILD_PREFIX}/share/gnuconfig/config.guess" config/config.guess
cp "${BUILD_PREFIX}/share/gnuconfig/config.sub" config/config.sub
./configure \
    --prefix="${PREFIX}" \
    --build="${BUILD}" \
    --host="${HOST}" \
    --disable-link-static \
    --disable-debug
make -j"${CPU_COUNT}"
make install
rm -f "${PREFIX}/lib/libmonitor.la"
