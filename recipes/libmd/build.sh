#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make check
make install
