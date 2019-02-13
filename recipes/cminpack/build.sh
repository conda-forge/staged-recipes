#!/bin/bash
mkdir build
cd build

CMAKE_BUILD_TYPE=RelWithDebInfo

cmake -G "Ninja" \
  -D BUILD_SHARED_LIBS:BOOL=ON \
  -D CMAKE_PREFIX_PATH=$PREFIX \
  -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
  -D CMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
  -D CMINPACK_LIB_INSTALL_DIR="lib" \
  -D USE_BLAS:BOOL=OFF \
  ..

ninja
ninja install

ctest --output-on-failure
