#!/bin/bash
set -euxo pipefail

rm GPUArchitectureGenerator/isa_spec_manager/tinyxml2.cpp GPUArchitectureGenerator/isa_spec_manager/tinyxml2.h

# CMAKE_ARGS contains separate command-line options.
# shellcheck disable=SC2086
cmake -GNinja ${CMAKE_ARGS} \
    -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
    -DROCROLLER_ENABLE_CLIENT=OFF \
    -DROCROLLER_BUILD_TESTING=OFF \
    -DBUILD_TESTING=OFF \
    -DROCROLLER_ENABLE_TEST_DISCOVERY=OFF \
    -DROCROLLER_ENABLE_GEMM_CLIENT_TESTS=OFF \
    -DROCROLLER_ENABLE_PREGENERATED_ARCH_DEF=ON \
    -DROCROLLER_ENABLE_FETCH=OFF \
    -DROCROLLER_BUILD_SHARED_LIBS=ON \
    -Bbuild -S.
cmake --build ./build --parallel "${CPU_COUNT}"
cmake --install ./build
