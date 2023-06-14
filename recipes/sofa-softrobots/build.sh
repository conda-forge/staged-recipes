#!/bin/sh

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} -B . -S .. \
  -DPYTHON_EXECUTABLE=$CONDA_PREFIX/bin/python \
  -DPython_FIND_STRATEGY=LOCATION \
  -DSOFTROBOTS_BUILD_TESTS=OFF

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install 
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# test
ctest --parallel ${CPU_COUNT} --verbose