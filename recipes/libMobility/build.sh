#!/bin/bash

set -euxo pipefail
rm -rf build || true
mkdir build
cd build
CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DPython3_EXECUTABLE=${PYTHON}"
CMAKE_FLAGS+=" -DCMAKE_INCLUDE_PATH=${PREFIX}/include"
CMAKE_FLAGS+=" -DMKL_INCLUDE_DIR=${PREFIX}/include"
cmake  ${SRC_DIR} ${CMAKE_FLAGS}
make install -j$CPU_COUNT
