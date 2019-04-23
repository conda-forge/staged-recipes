#!/bin/bash

set -euo pipefail

export CMAKE_CONFIG="Release"

mkdir "build_${CMAKE_CONFIG}"
cd "build_${CMAKE_CONFIG}"

cmake \
    -G "Unix Makefiles" \
    -D CMAKE_BUILD_TYPE:STRING="Release" \
    -D BUILD_SHARED_LIBS:BOOL="ON" \
    -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL="ON" \
    -D CMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -D CMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    "${SRC_DIR}"

make -j${CPU_COUNT}
make install
