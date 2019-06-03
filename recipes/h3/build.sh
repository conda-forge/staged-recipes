#!/usr/bin/env bash

set -ex

export LDFLAGS="$LDFLAGS -lrt"

cmake \
  -DENABLE_FORMAT=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
  .

make h3 -j${CPU_COUNT} VERBOSE=1
make install
