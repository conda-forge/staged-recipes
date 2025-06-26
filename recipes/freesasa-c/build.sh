#!/bin/bash

set -exo pipefail

cd "${SRC_DIR}"

autoreconf -fvi

if [[ "${target_platform}" == "win-"* ]]; then
    # Use `-disable-json ` due to no m2-json-c package
    ./configure --prefix="${PREFIX}" \
        --disable-json \
        --enable-shared \
        --disable-static \
        --disable-debug \
        --disable-dependency-tracking \
        --enable-silent-rules \
        --disable-option-checking
else
    ./configure --prefix="${PREFIX}" \
        --enable-shared \
        --disable-static \
        --disable-debug \
        --disable-dependency-tracking \
        --enable-silent-rules \
        --disable-option-checking
fi

if [[ "${target_platform}" == "linux-"* ]]; then
    sed -i.bak 's|-lc++|-lstdc++|' src/Makefile
fi

make -j"${CPU_COUNT}"
make install
