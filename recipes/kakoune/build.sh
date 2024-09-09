#!/bin/bash

set -exo pipefail

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    make install -j${CPU_COUNT} \
        debug=no \
        PREFIX=${PREFIX} \
        CXX=${CXX}
elif [[ "$OSTYPE" == "darwin"* ]]; then
    make install \
        debug=no \
        PREFIX=${PREFIX} \
        CXX=${CLANG} \
        CPPFLAGS-os-Darwin="-I${BUILD_PREFIX}/include" \
        LDFLAGS-os-Darwin="-L${BUILD_PREFIX}/lib"
fi
