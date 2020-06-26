#!/usr/bin/env bash

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DWITH_ZSTD=ON \
    ..


make "-j${CPU_COUNT}"

make ARGS="-V" test

make "-j${CPU_COUNT}" install
