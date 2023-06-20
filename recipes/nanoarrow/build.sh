#!/bin/bash

mkdir build
cd build
cmake ${CMAKE_ARGS} -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release ..
make install