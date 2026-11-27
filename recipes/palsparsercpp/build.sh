#!/bin/bash
set -euxo pipefail

# The test suite uses std::filesystem, which libc++'s availability markings
# reject for older macOS deployment targets. The shipped library does not use
# it, so turning the markings off affects the tests only.
if [[ "${target_platform}" == osx-* ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# AtomicAndPhysicalConstantsCLib: a static, position-independent archive that is
# bundled into libPALSParserCpp, as PALSParserCpp's own vendored build does.
cmake ${CMAKE_ARGS} -S apc -B build-apc -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DAPC_BUILD_TESTS=OFF
cmake --build build-apc --target apc

# rapidyaml, PCRE2 and Catch2 come from the host environment.
cmake ${CMAKE_ARGS} -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DPALS_USE_SYSTEM_DEPS=ON \
  -DBUILD_TESTING=ON \
  -DPALS_BUILD_EXAMPLES=OFF \
  -DPALS_APC_INCLUDE_DIR="${SRC_DIR}/apc/include" \
  -DPALS_APC_LIBRARY="${SRC_DIR}/build-apc/libapc.a"
cmake --build build

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  ctest --test-dir build --output-on-failure
fi

# The library, its C header and its license; no tests, examples or dependencies.
cmake --install build --component PALSParserCpp
