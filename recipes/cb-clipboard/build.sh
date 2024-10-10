#!/bin/bash

set -exuo pipefail

export OPENSSL_ROOT_DIR=${PREFIX}
export OPENSSL_INCLUDE_DIR=${OPENSSL_ROOT_DIR}/include/openssl
export OPENSSL_CRYPTO_LIBRARY=${OPENSSL_ROOT_DIR}/lib/libcrypto.so.3
mkdir -p build
cd build

if [[ "${target_platform}" == "linux-"* ]]; then
    cmake ${CMAKE_ARGS} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        ..
elif [[ "${target_platform}" == "osx-"* ]]; then

    cmake ${CMAKE_ARGS} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_OSX_ARCHITECTURES=${OSX_ARCH} \
        ..
fi

make -j${CPU_COUNT}
make install
