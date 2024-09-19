#!/bin/bash

set -exo pipefail

echo "${target_platform}"

if [[ "${target_platform}" == "linux-"* || "${target_platform}" == "win"* ]]; then
    make install -j${CPU_COUNT} \
        debug=no \
        PREFIX=${PREFIX} \
        CXX=${CXX}

elif [[ "${target_platform}" == "osx-"* ]]; then
    make install -j${CPU_COUNT} \
        debug=no \
        PREFIX=${PREFIX} \
        CXX=${CXX} \
        CPPFLAGS-os-Darwin="-I${BUILD_PREFIX}/include" \
        LDFLAGS-os-Darwin="-L${BUILD_PREFIX}/lib"
fi
