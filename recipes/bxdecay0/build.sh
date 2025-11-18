#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ "${DEBUG_C:-no}" == "yes" ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

cmake -S . -B build \
    -D CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D BUILD_TESTING=ON \
    -D BXDECAY0_WITH_GEANT4_EXTENSION=ON \
    ${CMAKE_ARGS} \
    "${SRC_DIR}"

cmake --build build -j${CPU_COUNT}

ctest -V --test-dir build

cmake --install build
