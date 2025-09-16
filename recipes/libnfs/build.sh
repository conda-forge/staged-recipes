#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export ACLOCAL_PATH=${PREFIX}/share/aclocal
./bootstrap
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make check
make install
