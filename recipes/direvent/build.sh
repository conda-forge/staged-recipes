#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i '/change.at/d' tests/Makefile.am
sed -i '/change.at/d' tests/testsuite.at

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make
make check
make install
