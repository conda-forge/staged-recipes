#!/usr/bin/env bash

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DMSGPACK_CXX11=YES \
    ..

ninja install
