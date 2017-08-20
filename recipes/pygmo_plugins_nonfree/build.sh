#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPAGMO_PLUGINS_NONFREE_BUILD_PYTHON=yes \
    -DPAGMO_PLUGINS_NONFREE_BUILD_TESTS=no \
    ..

make

make install
