#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --prefix=${PREFIX} \
    --with-readline=${PREFIX}

export CFLAGS="${CFLAGS} -Wno-incompatible-function-pointer-types"
make CC=${CC} -j${CPU_COUNT}
./install
