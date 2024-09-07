#!/bin/bash

set -exo pipefail

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

ln -s ${CXX} ${BUILD_PREFIX}/bin/c++
make install debug=no PREFIX=${PREFIX} LDFLAGS="${LDFLAGS}" -j${CPU_COUNT}
unlink ${BUILD_PREFIX}/bin/c++
