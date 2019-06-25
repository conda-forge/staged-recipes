#!/bin/bash

export CPATH=$PREFIX/include

mkdir build
cd build

# Configure step
cmake .. \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_VERBOSE_MAKEFILE=ON

# Build step
ninja install
