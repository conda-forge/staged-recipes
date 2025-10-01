#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

AUTOMAKE_FLAGS=--include-deps
./autogen.sh

./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make check
make install
