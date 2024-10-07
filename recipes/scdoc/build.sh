#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-strict-prototypes"
make LDFLAGS=${LDFLAGS} PREFIX=${PREFIX} -j${CPU_COUNT}
make install PREFIX=${PREFIX}
