#!/bin/sh

mkdir build
cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make install
make basicstuff -j${CPU_COUNT}
ctest -R basicstuff*
