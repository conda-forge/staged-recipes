#!/bin/bash

mkdir build
cd build

# Configure the build of reakplot
cmake -GNinja .. ${CMAKE_ARGS}  \
    -DCMAKE_BUILD_TYPE=Release  \
    -DPYTHON_EXECUTABLE=$PYTHON

# Build and install reakplot in $PREFIX
ninja install
