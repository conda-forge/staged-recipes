#!/bin/bash

set -euxo pipefail

rm -rf build || true

CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DTorch_DIR=$CONDA_PREFIX/lib/python3.9/site-packages/torch/share/cmake/Torch"
CMAKE_FLAGS+=" -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX"
CMAKE_FLAGS+=" -DCMAKE_CUDA_ARCHITECTURES=70"

mkdir build && cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT
make -j$CPU_COUNT install
