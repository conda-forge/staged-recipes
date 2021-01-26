#!/bin/bash

set -euxo pipefail

CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release"

mkdir build
cd build

cmake ${CMAKE_FLAGS} ${SRC_DIR}
make -j${CPU_COUNT}

cp smina ${PREFIX}/bin
cp libsmina.a ${PREFIX}/lib

mkdir -p ${PREFIX}/share/smina/examples
cp ../examples/* ${PREFIX}/share/smina/examples