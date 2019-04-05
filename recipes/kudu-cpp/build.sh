#!/usr/bin/env bash

# thirdparty/build-if-necessary.sh

mkdir -p build/release

cd build/release

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=release \
  ../..

make -j $CPU_COUNT
make install
