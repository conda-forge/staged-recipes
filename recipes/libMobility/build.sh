#!/bin/bash

set -euxo pipefail
rm -rf build || true
mkdir build
cd build
CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DPython_EXECUTABLE=${PYTHON}"
CMAKE_FLAGS+=" -DCMAKE_VERBOSE_MAKEFILE=y"
cmake ${SRC_DIR} ${CMAKE_FLAGS}
make install -j$CPU_COUNT
