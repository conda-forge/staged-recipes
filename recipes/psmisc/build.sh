#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/AT_NO_AUTOMOUNT|AT_STATX_DONT_SYNC/0/' src/statx.c

./autogen.sh
./configure --disable-statx \
    --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make check
make install
