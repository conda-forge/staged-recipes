#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/shar-3//' tests/Makefile.am

export CFLAGS="${CFLAGS} -fcommon"
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make check
make install
