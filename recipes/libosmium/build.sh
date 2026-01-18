#! /bin/bash
set -e

extra_cmake_args=(
    -GNinja
    -DWERROR=OFF
)

mkdir build && cd build

cmake ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    $SRC_DIR

ninja
ninja install