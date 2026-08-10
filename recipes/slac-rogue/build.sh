#!/bin/bash
set -ex

CPU_COUNT="${CPU_COUNT:-$(nproc)}"

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
    -DROGUE_INSTALL=conda \
    -DROGUE_DIR=${PREFIX} \
    -DROGUE_VERSION=v${PKG_VERSION} \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE="$PYTHON"

cmake --build . -j ${CPU_COUNT}
cmake --install .
