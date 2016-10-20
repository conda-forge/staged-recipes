#!/bin/sh

mkdir -p build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DFMILIB_INSTALL_PREFIX=${PREFIX} \
  ..

make install -j${CPU_COUNT}
