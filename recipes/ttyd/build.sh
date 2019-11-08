#!/usr/bin/env bash
set -ex

mkdir -p build
pushd build

cmake \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make -j "${CPU_COUNT}"
# no make check
make install

popd
