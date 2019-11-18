#!/usr/bin/env bash
set -ex

mkdir build
pushd build

export XDG_DATA_HOME="${PREFIX}/share"
export XDG_DATA_DIRS="${PREFIX}/share:${XDG_DATA_DIRS}"

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release     \
      -Wno-dev \
      ..

make -j ${CPU_COUNT}
ctest -E "kdirwatch_qfswatch_unittest|kautosavefiletest"
make install
popd
