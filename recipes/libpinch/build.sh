#!/bin/bash
set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

if [[ ${target_platform} == "linux-"* ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DBUILD_SHARED_LIBS=ON -DPINCH_BUILD_TESTS=ON"

    if [[ ${build_platform} != ${target_platform} ]]; then
        CMAKE_ARGS="${CMAKE_ARGS} -DTEST_STD_CHRONO_FROM_STREAM_R=ON"
    fi
elif [[ ${target_platform} == "osx-"* ]]; then
    # Test code is not written for mac
    CMAKE_ARGS="${CMAKE_ARGS} -DBUILD_SHARED_LIBS=ON"
fi

cmake -S . -B build ${CMAKE_ARGS}

cmake --build build --parallel ${CPU_COUNT}

ctest -V --test-dir build
cmake --install build
