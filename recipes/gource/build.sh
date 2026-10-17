#!/usr/bin/env bash
set -euxo pipefail

./configure \
    --prefix="${PREFIX}" \
    --with-boost="${PREFIX}" \
    --with-boost-libdir="${PREFIX}/lib" \
    --disable-dependency-tracking

make -j"${CPU_COUNT}"
make install
