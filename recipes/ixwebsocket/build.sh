#!/bin/bash

set -xeo pipefail

mkdir build
cd build

cmake \
  -LAH \
  ${CMAKE_ARGS} \
  ..

make -j ${CPU_COUNT}

make install
