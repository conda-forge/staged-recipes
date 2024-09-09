#!/bin/bash

set -exo pipefail

cd ${SRC_DIR}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    make install -j${CPU_COUNT} \
        debug=no \
        PREFIX=${PREFIX} \
        CXX=${CXX}
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export CXX="${CC_FOR_BUILD}-cpp"

    make install \
        debug=no \
        PREFIX=${PREFIX} \
        CXX=${CXX} \
        CPPFLAGS-os-Darwin="-I${PREFIX}/include" \
        LDFLAGS-os-Darwin="-L${PREFIX}/lib"
fi
