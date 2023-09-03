#!/usr/bin/env bash
set -e

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -S ${SRC_DIR} \
    -B . \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_PREFIX_PATH=${PREFIX} \
    -D CMAKE_INSTALL_PREFIX=${LIBRARY_PREFIX} \
    -D PYTHON_EXECUTABLE=${PYTHON} \
    -D COMPILER=AUTO \
    -D OPENMP=FALSE \
    -D CUDA=${BUILD_CUDA} \
    -D SECP256K1_ENABLE_MODULE_ECDH=ON \
    -D SECP256K1_ENABLE_MODULE_RECOVERY=OFF \
    -D SECP256K1_ENABLE_MODULE_EXTRAKEYS=ON \
    -D SECP256K1_ENABLE_MODULE_SCHNORRSIG=ON \
    -D SECP256K1_EXPERIMENTAL=OFF \
    -D SECP256K1_USE_EXTERNAL_DEFAULT_CALLBACKS=OFF \
    -D SECP256K1_INSTALL=ON

cmake --build .

cmake --build . --target install

make check
