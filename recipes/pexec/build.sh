#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make -j${CPU_COUNT} check
make -j${CPU_COUNT} install
