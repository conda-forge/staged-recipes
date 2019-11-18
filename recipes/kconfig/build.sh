#!/usr/bin/env bash
set -ex

mkdir build
pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release     \
      -Wno-dev \
      ..

make -j ${CPU_COUNT}
ctest -E "kconfigcore-kconfigtest"
make install
popd
