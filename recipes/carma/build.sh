#!/bin/bash

set -xeo pipefail

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCARMA_INSTALL_LIB:BOOL=ON \
    ..

cmake --build . --config Release --target install