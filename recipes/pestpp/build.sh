#!/bin/bash

mkdir build
cd build

cmake ${CMAKE_ARGS} ..             \
    -GNinja                        \
    -DBUILD_SHARED_LIBS=ON         \
    -DCMAKE_BUILD_TYPE=Release     \
    -DCMAKE_PREFIX_PATH=$PREFIX    \
    -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build . --target install
