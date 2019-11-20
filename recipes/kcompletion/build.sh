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
# skip tests the fail headlessly
ctest -E "kcompletioncoretest|klineedit_unittest|kcombobox_unittest"
make install
popd
