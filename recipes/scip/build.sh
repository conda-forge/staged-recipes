#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Bliss with SCIP patch being privately vendored
cmake -B bliss-build -S "${SRC_DIR}/bliss" \
      -D CMAKE_INSTALL_PREFIX="${PWD}/bliss-install" \
      -D CMAKE_BUILD_TYPE=Release \
      -D BUILD_SHARED_LIBS=OFF
cd bliss-build
make -j${CPU_COUNT}
make install
cd -

# we need librt
if test "${OSTYPE}" == "linux-gnu"
then
    export LDFLAGS="-lrt ${LDFLAGS}"
fi

# BLISS_DIR is looked up in scip/cmake/Modules.FindBliss.cmake
cmake -B scip-build -S "${SRC_DIR}/scip" \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
      -D BLISS_DIR="${PWD}/bliss-install" \
      -D READLINE=ON \
      -D PARASCIP=ON \
      -D IPOPT=ON

cd scip-build
make -j${CPU_COUNT} libscip scip
make install
