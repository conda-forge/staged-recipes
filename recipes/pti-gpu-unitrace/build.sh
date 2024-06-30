#!/bin/bash

set -euxo pipefail

cmake \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=icx \
    -DCMAKE_CXX_COMPILER=icpx \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DBUILD_WITH_MPI=OFF \
    -DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
    -S ./tools/unitrace \
    -B ./tools/unitrace/build 
cmake --build ./tools/unitrace/build
cmake --install ./tools/unitrace/build --prefix=${PREFIX}
