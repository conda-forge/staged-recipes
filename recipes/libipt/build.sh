#!/bin/bash

set -euxo pipefail

cmake \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
    -B ./build
cmake --build ./build
cmake --install ./build --prefix=$PREFIX
