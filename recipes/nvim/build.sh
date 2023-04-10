#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -G Ninja -B build \
    -DUSE_BUNDLED=OFF \
    -DLIBLUV_LIBRARY="${PREFIX}/lib/libluv${SHLIB_EXT}" \
    -DLIBUV_LIBRARY="${PREFIX}/lib/libuv${SHLIB_EXT}" \
    ${CMAKE_ARGS}
cmake --build build
cmake --install build
