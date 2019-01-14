#!/bin/sh

mkdir build
cd build

cmake \
  -GNinja \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  ..

cmake --build . --config Release --target install
ctest -C Release -V -j
