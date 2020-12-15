#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# we need librt
if test "${OSTYPE}" == "linux-gnu"
then
    export LDFLAGS="-lrt ${LDFLAGS}"
fi

cmake -B build -S "${SRC_DIR}" -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="${PREFIX}" -D BLA_VENDOR=Generic
cd build
make -j${CPU_COUNT} all
make install
