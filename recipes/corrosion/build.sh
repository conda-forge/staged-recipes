#!/bin/bash

set -exo pipefail

if [[ "${target_platform}" == "linux-"* ]]; then
    ln -s "${CC}" "${BUILD_PREFIX}/bin/cc"
    ln -s "${CXX}" "${BUILD_PREFIX}/bin/c++"
fi

# Use `lib` instead of `lib64` for tests
sed -i.bak '/include(GNUInstallDirs)/a\
set(CMAKE_INSTALL_LIBDIR lib CACHE STRING "" FORCE)
' cmake/Corrosion.cmake

cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -pthread" \
    -DCMAKE_EXE_LINKER_FLAGS="${CMAKE_EXE_LINKER_FLAGS} -pthread" \
    -DCORROSION_BUILD_TESTS=ON
cmake --build build --parallel ${CPU_COUNT}

ctest -V --test-dir build --parallel ${CPU_COUNT}
cmake --install build
