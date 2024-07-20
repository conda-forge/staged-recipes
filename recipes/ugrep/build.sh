#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --enable-color \
    --disable-silent-rules \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make
make install
