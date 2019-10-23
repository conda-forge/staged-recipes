#!/usr/bin/env bash

set -ex

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DINSTALL_HELPER_SCRIPTS=off \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DBUILD_STATIC=OFF \
  -DBUILD_TESTS=OFF \
  -DBUILD_LENSTOOL=OFF \
  -DBUILD_FOR_SSE=off \
  -DBUILD_FOR_SSE2=off \
  -DBUILD_DOC=OFF \
  .

make -k -j${CPU_COUNT} || true

make install
