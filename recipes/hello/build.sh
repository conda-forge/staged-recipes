#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ $target_platform =~ .*osx.* ]]; then
    LDFLAGS="${LDFLAGS} -liconv"
fi

./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make -j${CPU_COUNT} check
make -j${CPU_COUNT} install
