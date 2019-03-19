#!/bin/bash
mkdir -p build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ..

make VERBOSE=1 -j${CPU_COUNT}
make install
