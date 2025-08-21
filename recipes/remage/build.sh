#!/usr/bin/env bash

set -eux

if [[ "${DEBUG_C:-no}" == "yes" ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi


mkdir build && cd build

cmake \
    -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_STANDARD=17 \
    -DENABLE_TESTING=ON \
    "${CMAKE_PLATFORM_FLAGS[@]}" \
    "${SRC_DIR}"

make "-j${CPU_COUNT}" ${VERBOSE_CM:-}
make install "-j${CPU_COUNT}"
