#!/bin/bash

set -exo pipefail

export LIBRARY_PATH="${PREFIX}/lib"

ln -s ${CXX} ${BUILD_PREFIX}/bin/c++

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    make install -j${CPU_COUNT} \
        debug=no \
        PREFIX=${PREFIX}
elif [[ "$OSTYPE" == "darwin"* ]]; then
    make install -j${CPU_COUNT} \
        debug=no \
        PREFIX=${PREFIX} \
        CPPFLAGS-os-Darwin="-I${CONDA_PREFIX}/include" \
        LDFLAGS-os-Darwin="-L${CONDA_PREFIX}/lib"
fi
