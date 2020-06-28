#!/usr/bin/env bash

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DPYTHON_DESIRED=3 \
      -DENABLE_DRPM=ON \
      -DWITH_LIBMODULEMD=ON \
      -DWITH_ZCHUNK=ON \
      ..

make "-j${CPU_COUNT}"

make "-j${CPU_COUNT}" tests
make ARGS="-V" test

make "-j${CPU_COUNT}" install
