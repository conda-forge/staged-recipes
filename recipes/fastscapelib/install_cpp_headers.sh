#!/bin/bash

mkdir build_cpp
cd build_cpp

cmake $SRC_DIR \
      -DVERSION_TAG=$PKG_VERSION \
      -DBUILD_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib $SRC_DIR

make install
