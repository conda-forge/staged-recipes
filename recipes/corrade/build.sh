#!/bin/bash

set -exo pipefail

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake $SRC_DIR \
    ${CMAKE_ARGS} \
    -G Ninja \
    -B build \
    -DBUILD_SHARED_LIBS=ON \
    -DDCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release

cmake --build build --parallel

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --test-dir build --output-on-failure
fi

cmake --build build --target install
