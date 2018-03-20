#!/bin/bash
set -e
set -x
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE="Release" ${SRC_DIR}
make -j${CPU_COUNT}
make install
