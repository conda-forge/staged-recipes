#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build ${CMAKE_ARGS} -G Ninja \
    -DAPR_INSTALL=ON \
    -DAPR_BUILD_SHARED_LIB=ON \
    -DAPR_BUILD_STATIC_LIB=OFF \
    -DAPR_BUILD_EXAMPLES=OFF \
    -DAPR_USE_LIBTIFF=ON \
    -DAPR_TESTS=ON \
    -DAPR_PREFER_EXTERNAL_GTEST=ON \
    -DAPR_PREFER_EXTERNAL_BLOSC=ON \
    -DAPR_USE_CUDA=OFF \
    -DAPR_USE_OPENMP=ON \
    -DAPR_BENCHMARK=OFF \
    -DAPR_DENOISE=OFF

cmake --build build -j${CPU_COUNT}
if [[ ${target_platform} =~ .*linux.* ]]; then
    ctest --verbose --test-dir build
fi
cmake --install build
