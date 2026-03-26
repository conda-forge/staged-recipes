#!/bin/bash

set -euxo pipefail

# conda-forge fix for std::format/std::to_chars availability on macOS
if [[ "${target_platform}" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSPARROW_IPC_BUILD_SHARED=ON \
    -DSPARROW_IPC_BUILD_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    $SRC_DIR

make -j${CPU_COUNT} install
