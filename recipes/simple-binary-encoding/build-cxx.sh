#!/bin/bash

set -xeo pipefail

mkdir build
cd build

cmake \
  -LAH \
  ${CMAKE_ARGS} \
  -DSBE_TESTS:BOOL=OFF \
  -DSBE_BUILD_BENCHMARKS:BOOL=OFF \
  -DSBE_BUILD_SAMPLES:BOOL=OFF \
  ..

cmake --build . --clean-first

ctest

exit 1
