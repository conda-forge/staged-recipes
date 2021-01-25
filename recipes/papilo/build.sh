#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# we need librt
if [ "${OSTYPE}" == "linux-gnu" ] ; then
    export LDFLAGS="-lrt ${LDFLAGS}"
fi

cmake -B build -S "${SRC_DIR}" -D CMAKE_BUILD_TYPE=Release -D BLA_VENDOR=Generic
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --prefix "${PREFIX}"
