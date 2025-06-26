#!/bin/bash

set -exo pipefail

cd "${SRC_DIR}"

if [[ "${target_platform}" == "win-"* ]]; then
    export CC="${BUILD_PREFIX}/bin/gcc.exe"
    export CXX="${BUILD_PREFIX}/bin/g++.exe"
    unset INCLUDE
    unset LIB
fi

if [[ "${target_platform}" == "linux-"* || "${target_platform}" == "osx-"* ]]; then
    autoreconf -fvi
fi

./configure --prefix="${PREFIX}" \
    --enable-shared \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-silent-rules \
    --disable-option-checking

if [[ "${target_platform}" == "linux-"* ]]; then
    sed -i.bak 's|-lc++|-lstdc++|' src/Makefile
fi

make -j"${CPU_COUNT}"
make install
