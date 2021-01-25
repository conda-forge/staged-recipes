#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Bliss with SCIP patch being privately vendored
cmake -B bliss-build -S "${SRC_DIR}/bliss" -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=OFF
cmake --build bliss-build --parallel ${CPU_COUNT}
cmake --install bliss-build --prefix "${PWD}/bliss-install"

# we need librt
if [ "${OSTYPE}" == "linux-gnu" ] ; then
    export LDFLAGS="-lrt ${LDFLAGS}"
fi

# BLISS_DIR is looked up in scip/cmake/Modules.FindBliss.cmake
cmake -B scip-build -S "${SRC_DIR}/scip" \
      -D CMAKE_BUILD_TYPE=Release \
      -D BLISS_DIR="${PWD}/bliss-install" \
      -D READLINE=ON \
      -D PARASCIP=ON \
      -D IPOPT=ON
cmake --build scip-build --parallel ${CPU_COUNT}
cmake --install scip-build --prefix "${PREFIX}"
