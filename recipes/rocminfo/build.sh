#!/bin/bash

sed -i 's@set(CMAKE_CXX_FLAGS "-std=c++11 ")@@g' CMakeLists.txt

mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DROCM_DIR=$PREFIX \
  -DROCRTST_BLD_TYPE=Release \
  ..

make VERBOSE=1 -j${CPU_COUNT}
make install
