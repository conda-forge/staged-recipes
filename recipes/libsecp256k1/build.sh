#!/usr/bin/env bash
set -e

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

cmake ${CMAKE_ARGS} \
    -S ${SRC_DIR} \
    -B . \
    -D SECP256K1_ENABLE_MODULE_RECOVERY=${SECP256K1_ENABLE_MODULE_RECOVERY} \
    -D SECP256K1_INSTALL=ON

cmake --build . --config Release --parallel ${CPU_COUNT}
# cmake --build . --target check
cmake --build . --target install
