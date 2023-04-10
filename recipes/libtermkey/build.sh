#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cp ${RECIPE_DIR}/CMakeLists.txt ${SRC_DIR}

cmake -S . -G Ninja -B build \
    -DUNIBILIUM_INCLUDE_DIRS=${PREFIX}/include \
    -DUNIBILIUM_LIBRARIES=${PREFIX}/lib/libunibilium${SHLIB_EXT} \
    -DBUILD_SHARED_LIBS=ON \
    ${CMAKE_ARGS}
cmake --build build
cmake --install build
