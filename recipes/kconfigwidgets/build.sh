#!/usr/bin/env bash
set -ex

mkdir build
pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release     \
      -DKDE_INSTALL_LIBDIR=lib \
      -Wno-dev \
      ..

make -j ${CPU_COUNT}
ctest -E "kstandardactiontest|kconfigdialog_unittest|kcolorschemetest|krecentfilesaction_test"
make install
popd
