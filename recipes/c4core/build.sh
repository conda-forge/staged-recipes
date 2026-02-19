#!/bin/bash

# Copy the downloaded dependencies in meta.yaml to the dirs expected by c4core
# NOTE: These dependencies are not vendored by c4core! They are small and specific to c4core.
cp -r deps/cmake .
cp -r deps/debugbreak ./src/c4/ext

# Configure the build of the library
mkdir build
cd build
cmake -GNinja .. ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON

# Build and install the library in $PREFIX
ninja install
