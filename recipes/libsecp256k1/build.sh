#!/usr/bin/env bash
set -e

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

cmake ${CMAKE_ARGS} \
    -S ${SRC_DIR} \
    -B . \
    -D SECP256K1_ENABLE_MODULE_ECDH=ON \
    -D SECP256K1_ENABLE_MODULE_RECOVERY=OFF \
    -D SECP256K1_ENABLE_MODULE_EXTRAKEYS=ON \
    -D SECP256K1_ENABLE_MODULE_SCHNORRSIG=ON \
    -D SECP256K1_EXPERIMENTAL=OFF \
    -D SECP256K1_USE_EXTERNAL_DEFAULT_CALLBACKS=OFF \
    -D SECP256K1_INSTALL=ON

cmake --build . --config Release --parallel ${CPU_COUNT}
cmake --build . --target check
cmake --build . --target install
