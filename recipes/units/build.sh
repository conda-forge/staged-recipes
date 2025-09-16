#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --with-installed-readline \
    --prefix=${PREFIX}
make check
make install
