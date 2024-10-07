#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --mandir=${PREFIX}/share/man
make -j${CPU_COUNT} install
