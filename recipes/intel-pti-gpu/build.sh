#!/bin/bash

set -euxo pipefail

cmake \
    -G Ninja \
    -DCMAKE_C_COMPILER=icx \
    -DCMAKE_CXX_COMPILER=icpx \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DPTI_BUILD_TESTING=OFF \
    -DPTI_BUILD_SAMPLES=OFF \
    -DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
    -S ./sdk \
    -B ./sdk/build 
cmake --build ./sdk/build
