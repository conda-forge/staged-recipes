#!/bin/sh

mkdir build && cd build

cmake -GNinja ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      -DUAPP_INTERNAL_OPEN62541=OFF \
      -DUAPP_BUILD_TESTS=OFF \
      -DUAPP_BUILD_EXAMPLES=OFF \
      -DUAPP_BUILD_DOCUMENTATION=OFF \
      $SRC_DIR

cmake --build .
cmake --install .
