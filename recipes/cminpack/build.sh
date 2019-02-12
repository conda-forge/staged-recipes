#!/bin/bash
mkdir build
cd build

CMAKE_BUILD_TYPE=RelWithDebInfo

cmake -G "Ninja" \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH=$LIBRARY_PREFIX \
  -DCMAKE_INSTALL_PREFIX:PATH=$LIBRARY_PREFIX \
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
  -DINTEL_MKL_DIR=$LIBRARY_PREFIX ..

ninja
ninja install

ctest --output-on-failure
