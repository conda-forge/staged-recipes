#!/bin/bash

set -exuo pipefail

export OPENSSL_ROOT_DIR=${PREFIX}
echo $MACOSX_DEPLOYMENT_TARGET

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
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
        ..
fi

make -j${CPU_COUNT}
make install