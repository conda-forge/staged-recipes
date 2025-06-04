#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export ACLOCAL_PATH=${PREFIX}/share/aclocal
autoreconf --force --verbose --install
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make -j${CPU_COUNT} check
make -j${CPU_COUNT} install
