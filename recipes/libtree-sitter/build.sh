#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cp ${RECIPE_DIR}/CMakeLists.txt ${SRC_DIR}

cmake -S . -G Ninja -B build \
    -DBUILD_SHARED_LIBS=ON \
    ${CMAKE_ARGS}
cmake --build build
cmake --install build
