#!/bin/bash

set -exuo pipefail

export CFLAGS="${CFLAGS/-Os/-O3}"
export CXXFLAGS="${CXXFLAGS/-Os/-O3}"

mkdir -p build
cd build

if [[ "${target_platform}" == "linux-"* ]]; then
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        ..
elif [[ "${target_platform}" == "osx-"* ]]; then
    export MACOSX_DEPLOYMENT_TARGET=11.0
    export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
    
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_OSX_ARCHITECTURES=${OSX_ARCH} \
        ..
fi

make -j${CPU_COUNT}
make install
