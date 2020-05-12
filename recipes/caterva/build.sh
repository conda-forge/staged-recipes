#!/bin/bash

mkdir build
cd build

cmake -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE="Release" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
      -DSTATIC_LIB:BOOL=OFF \
      -DSHARED_LIB:BOOL=ON \
      "${SRC_DIR}"

cmake --build .
ctest
cmake --build . --target install
