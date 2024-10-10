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
    -DBUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DLIB_SUFFIX="" \
    -DMAGNUM_WITH_ASSIMPIMPORTER=ON \
    -DMAGNUM_WITH_BASISIMAGECONVERTER=ON \
    -DMAGNUM_WITH_BASISIMPORTER=ON \
    -DMAGNUM_WITH_GLTFIMPORTER=ON \
    -DMAGNUM_WITH_KTXIMAGECONVERTER=ON \
    -DMAGNUM_WITH_KTXIMPORTER=ON \
    -DMAGNUM_WITH_STBIMAGECONVERTER=ON \
    -DMAGNUM_WITH_STBIMAGEIMPORTER=ON \
    -DMAGNUM_WITH_STBTRUETYPEFONT=ON

cmake --build build --parallel

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --test-dir build --output-on-failure
fi

cmake --build build --target install
