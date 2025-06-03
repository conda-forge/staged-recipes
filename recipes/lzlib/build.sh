#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --enable-shared \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    CC=${CC}

make -j${CPU_COUNT} check
make -j${CPU_COUNT} install
