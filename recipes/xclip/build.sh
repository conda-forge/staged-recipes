#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

autoreconf -fiv
./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make -j${CPU_COUNT} install
