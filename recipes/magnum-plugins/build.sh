#!/bin/bash

set -exo pipefail

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

build_dir=$SRC_DIR-build

cmake $SRC_DIR \
    ${CMAKE_ARGS} \
    -G Ninja \
    -B $build_dir \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DLIB_SUFFIX="" \
    -DBUILD_TESTS=OFF \
    -DMAGNUM_WITH_ASSIMPIMPORTER=ON

cmake --build $build_dir --parallel

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --test-dir $build_dir --output-on-failure
fi

cmake --build $build_dir --target install
