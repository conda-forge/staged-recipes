#!/usr/bin/env bash
set -e

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

cmake .. -DCMAKE_PREFIX_PATH=${PREFIX} ${CMAKE_ARGS} ${SECP256K1_OPTIONS}

cmake --build . --target install ${CMAKE_BUILD_OPTIONS}

make check
