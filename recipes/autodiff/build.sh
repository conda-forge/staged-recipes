#!/bin/bash

mkdir build
cd build

# Configure step
cmake .. \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \

# Build step
ninja install -j${CPU_COUNT}
