#!/bin/bash
set -exo pipefail

cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DKOMPUTE_OPT_INSTALL=ON \
    -DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=OFF \
    -DKOMPUTE_OPT_USE_BUILT_IN_FMT=OFF \
    -DKOMPUTE_OPT_USE_BUILT_IN_SPDLOG=OFF \
    -DKOMPUTE_OPT_USE_SPDLOG=OFF \
    -DKOMPUTE_OPT_BUILD_PYTHON=ON \
    -DKOMPUTE_OPT_USE_BUILT_IN_PYBIND11=OFF \
    -DKOMPUTE_OPT_BUILD_TESTS=OFF \
    -DKOMPUTE_OPT_BUILD_DOCS=OFF \
    -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# Copy build output kp*.so to site-packages
find build -name "kp*.so" -exec install -m 755 {} "${SP_DIR}/kp$(python3-config --extension-suffix)" \;
