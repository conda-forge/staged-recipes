#!/bin/bash

mkdir build
cd build
cmake -D BUILD_SHARED=OFF -D BUILD_TESTING=OFF -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBDIR=$PREFIX/lib -D CMAKE_INSTALL_PREFIX=$PREFIX ..
make
make install
