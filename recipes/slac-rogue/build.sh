#!/bin/bash
set -ex

cmake ${CMAKE_ARGS} \
    -DROGUE_INSTALL=conda \
    -DROGUE_DIR=${PREFIX} \
    -DROGUE_VERSION=v${PKG_VERSION} \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE="$PYTHON" \
    -S "${SRC_DIR}" \
    -B build

cmake --build build --parallel ${CPU_COUNT}
cmake --install build
