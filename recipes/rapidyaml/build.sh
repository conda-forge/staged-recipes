#!/bin/bash

# Git clone submodules
git submodule update --init --recursive

# Configure the build of the library
mkdir build
cd build
cmake -GNinja .. ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release

# Build and install the library in $PREFIX
ninja install
