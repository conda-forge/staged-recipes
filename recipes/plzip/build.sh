#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    CXX=${CXX} \
    CXXFLAGS="-I${PREFIX}/include" \
    LDFLAGS="-L${PREFIX}/lib"

make
make install
