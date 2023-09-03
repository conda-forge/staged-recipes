#!/usr/bin/env bash
set -e

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

cmake ..    -D CMAKE_INSTALL_PREFIX=${PREFIX}\
            ${CMAKE_ARGS} \
            -D SECP256K1_ENABLE_MODULE_ECDH=ON \
            -D SECP256K1_ENABLE_MODULE_RECOVERY=OFF \
            -D SECP256K1_ENABLE_MODULE_EXTRAKEYS=ON \
            -D SECP256K1_ENABLE_MODULE_SCHNORRSIG=ON \
            -D SECP256K1_EXPERIMENTAL=OFF \
            -D SECP256K1_USE_EXTERNAL_DEFAULT_CALLBACKS=OFF \
            -D SECP256K1_INSTALL=ON

cmake --build . --target install ${CMAKE_BUILD_OPTIONS}

make check
