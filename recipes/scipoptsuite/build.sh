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
cmake -B scipoptsuite-build -S "${SRC_DIR}/scipoptsuite" \
      -D CMAKE_BUILD_TYPE=Release \
      -D PARASCIP=ON \
      -D PAPILO=ON \
      -D SOPLEX=ON \
      -D GCG=ON \
      -D BOOST=ON \
      -D GMP=ON \
      -D QUADMATH=ON \
      -D IPOPT=ON \
      -D ZLIB=ON \
      -D READLINE=ON \
      -D SYM=bliss \
      -D BLISS_DIR="${PWD}/bliss-install" \
      -D EXPRINT=cppad \
      -D GSL=ON \
      -D CLIQUER=ON
cmake --build scipoptsuite-build --parallel ${CPU_COUNT}
cmake --install scipoptsuite-build --prefix "${PREFIX}"
