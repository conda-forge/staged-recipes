#!/bin/bash

set -xeo pipefail

mkdir build
cd build

cmake \
  -LAH \
  ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DUSE_ZLIB=1 \
  -DUSE_TLS=1 \
  -DUSE_OPEN_SSL=1 \
  -DUSE_WS=1 \
  -DUSE_TEST=1 \
  ..

make -j ${CPU_COUNT}

make install
