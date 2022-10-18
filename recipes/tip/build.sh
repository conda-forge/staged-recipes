#!/bin/bash

mkdir build
cd build 

cmake ${CMAKE_ARGS} .. -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCONDA_PREFIX=$CONDA_PREFIX \
    -DUSER_VERSION=v1.0.0

ninja install -j8