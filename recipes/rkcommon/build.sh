#!/bin/bash
set -exo pipefail

cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=ON \
    -DRKCOMMON_STRICT_BUILD=OFF \
    -DRKCOMMON_WARN_AS_ERRORS=OFF \
    -DRKCOMMON_TASKING_SYSTEM=TBB \
    -DRKCOMMON_TBB_ROOT="${PREFIX}"

cmake --build build --parallel ${CPU_COUNT}
ctest -V --test-dir build --parallel ${CPU_COUNT}
cmake --install build
