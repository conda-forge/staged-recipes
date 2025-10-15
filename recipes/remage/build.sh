#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ "${DEBUG_C:-no}" == "yes" ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

if [[ "${target_platform}" == "osx-64" ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# prevent poluting the pycache directories with numba-compiled files from tests.
export NUMBA_CACHE_DIR="$PWD/build/.numba-cache"

cmake -S . -B build \
    -D CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D RMG_CONDA_BUILD=ON \
    -D BUILD_TESTING=ON \
    -D Python3_EXECUTABLE="$PYTHON" \
    -D FETCHCONTENT_TRY_FIND_PACKAGE_MODE="ALWAYS" \
    -D FETCHCONTENT_QUIET=OFF \
    -D FETCHCONTENT_FULLY_DISCONNECTED=OFF \
    -D CMAKE_REQUIRE_FIND_PACKAGE_fmt=ON \
    -D CMAKE_REQUIRE_FIND_PACKAGE_magic_enum=ON \
    -D CMAKE_REQUIRE_FIND_PACKAGE_CLI11=ON \
    ${CMAKE_ARGS} \
    "${SRC_DIR}"

cmake --build build -j${CPU_COUNT}

ctest -V --test-dir build --label-exclude "flaky|mt" -E observables

cmake --install build

# clean fontconfig cache that might have been written in the tests.
rm -r $PREFIX/var/cache/fontconfig
