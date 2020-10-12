#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -Gninja \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    ..

cmake --build . --target install
