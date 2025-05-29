#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i '/AM_C_PROTOTYPES/d' configure.ac

export CFLAGS="${CFLAGS} -DPROTOTYPES"
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make
make check
make install
