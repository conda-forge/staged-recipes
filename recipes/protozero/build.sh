#! /bin/bash
set -e

extra_cmake_args=(
    -GNinja
    -DCMAKE_INSTALL_LIBDIR=lib
    -DWERROR=OFF
)

mkdir build && cd build

cmake ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    $SRC_DIR

ninja

# The `install` command will take care of copying the files to the right place
ninja install
