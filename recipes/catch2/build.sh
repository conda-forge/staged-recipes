#!/bin/sh

mkdir build
cd build

cmake -LAH -G"Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  ..

# build and install
cmake --build . --target install

# test
ctest -R
