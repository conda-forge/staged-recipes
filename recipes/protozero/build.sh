#! /bin/bash
set -e

extra_cmake_args=(
    -GNinja
    -DWERROR=OFF
)

mkdir build && cd build

cmake ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    $SRC_DIR

ninja
ninja install
ninja test
