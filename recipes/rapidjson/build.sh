#!/bin/env bash

set -e

mkdir build-dir
cd build-dir

cmake -DRAPIDJSON_HAS_STDSTRING=ON \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DRAPIDJSON_BUILD_CXX11=ON \
      -DRAPIDJSON_BUILD_TESTS=OFF \
      -DRAPIDJSON_BUILD_EXAMPLES=OFF \
      -DRAPIDJSON_BUILD_DOC=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DCMAKE_BUILD_TYPE=release \
      ..

make -j${CPU_COUNT}
ctest
make install
