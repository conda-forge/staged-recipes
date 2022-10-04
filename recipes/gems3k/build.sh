#!/bin/bash

mkdir build
cd build

# Configure the build of GEMS3K
cmake -GNinja .. ${CMAKE_ARGS}  \
    -DCMAKE_BUILD_TYPE=Release

# Build and install GEMS3K in $PREFIX
ninja install
