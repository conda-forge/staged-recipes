#!/usr/bin/env bash
set -ex

mkdir build
pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release     \
      -Wno-dev \
      ..

make -j ${CPU_COUNT}
ctest -E "ecm_setup_version-old.*|ECMPoQmToolsTest|KDEFetchTranslations"
make install
popd
