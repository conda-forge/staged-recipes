#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make -j${CPU_COUNT} check
make -j${CPU_COUNT} install
