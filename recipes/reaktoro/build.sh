#!/bin/bash
echo CC=$CC
echo CXX=$CXX
which $CXX
$CXX --version
mkdir build
cd build
cmake -G Ninja \
      -DBUILD_ALL=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INCLUDE_PATH=$PREFIX/include \
      -DBOOST_INCLUDE_DIR=$PREFIX/include \
      -DPYTHON_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
      "-DTHIRDPARTY_COMMON_ARGS=-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON" \
      ..
cmake --build . --target install
