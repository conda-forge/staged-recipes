#!/bin/bash

set -exo pipefail

autoreconf -fvi
./configure --prefix="${PREFIX}" \
    --enable-shared \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-silent-rules \
    --disable-option-checking
if [[ "${target_platform}" == linux-* ]]; then
    sed -i.bak 's|-lc++|-lstdc++|' src/Makefile
fi

make -j"${CPU_COUNT}"
make install
