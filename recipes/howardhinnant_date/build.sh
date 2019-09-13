#!/bin/bash

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=ON
make
make install
