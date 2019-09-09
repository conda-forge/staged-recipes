#!/bin/bash

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR -DCMAKE_INSTALL_LIBDIR=lib
make
#cmake --build . --target testit
make install
