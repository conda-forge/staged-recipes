#!/bin/bash

set -euxo pipefail
rm -rf build || true
mkdir build
cd build
CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DPython3_EXECUTABLE=${PYTHON}"
cmake  ${SRC_DIR} ${CMAKE_FLAGS}
make install -j$CPU_COUNT
