#!/bin/sh
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release\
  -D CMAKE_INSTALL_PREFIX=$PREFIX\
  -D BUILD_CSM=OFF\
  -D BUILD_TESTS=OFF\
  -D CMAKE_OSX_DEPLOYMENT_TARGET=10.11\
  $SRC_DIR
make install
