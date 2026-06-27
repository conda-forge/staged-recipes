#!/usr/bin/env bash
set -euxo pipefail

# On macOS the default conda-forge SDK is older than what libc++ uses to gate
# newer C++ library features (e.g. floating-point std::from_chars) behind
# availability attributes. conda-forge ships its own modern libcxx at runtime,
# so disable the availability checks. See:
# https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
if [[ "$(uname)" == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# clair uses no C++20 modules; disable CMake's module dependency scanning so the
# build does not require clang-scan-deps (not shipped in this environment).
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DPython_EXECUTABLE="$PYTHON" \
  -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
  -DBuild_Tests=OFF \
  -DBuild_Documentation=OFF

cmake --build build -j"${CPU_COUNT}"
cmake --install build
