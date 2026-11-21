#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # C++20 library features newer than the deployment target
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

ARCH_ARGS=()
if [[ "${target_platform}" == *-64 ]]; then
  # KFR puts its symbols in a namespace named after the instruction set the
  # *consumer* is compiled for (conda-forge defaults: nocona = sse3 on linux-64,
  # core2 = ssse3 on osx-64). Build every level so that any -march links, with
  # sse2 as the baseline and runtime dispatch for the DFT and DSP kernels.
  ARCH_ARGS+=("-DKFR_ENABLE_MULTIARCH=ON" "-DKFR_ARCHS=sse2;sse3;ssse3;sse41;sse42;avx;avx2;avx512")
fi

# KFR fetches standalone Boost.Math with FetchContent for the elliptic filter
# design. Point it to a stub that exposes the Boost headers from the host
# environment instead, so nothing is downloaded at build time.
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DENABLE_TESTS=OFF \
  -DKFR_ENABLE_CAPI_BUILD=ON \
  "${ARCH_ARGS[@]}" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_BOOST_MATH="${RECIPE_DIR}/boost_math"

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
