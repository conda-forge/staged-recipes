#!/bin/bash

mkdir build
cd build

# Configure step
cmake .. \
    -GNinja \
    -DBUILD_SHARED_LIBS=ON \
    -DYAML_CPP_BUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \

# Build step
ninja install
