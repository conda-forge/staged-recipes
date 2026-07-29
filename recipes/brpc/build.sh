#!/bin/bash
set -exuo pipefail

cmake_args=(
  ${CMAKE_ARGS:-}
  -G Ninja
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"
  -DCMAKE_INSTALL_LIBDIR=lib
  # brpc declares cmake_minimum_required(VERSION 2.8.12), which CMake >= 4
  # refuses to configure without this override
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  -DBUILD_SHARED_LIBS=ON
  # on macOS brpc defaults OPENSSL_ROOT_DIR to Homebrew's /usr/local/opt/openssl
  # unless it is set explicitly, hiding the openssl from the host environment
  -DOPENSSL_ROOT_DIR="${PREFIX}"
  # the tools (rpc_press, rpc_view, ...) have no install rules upstream
  -DBUILD_BRPC_TOOLS=OFF
  -DDOWNLOAD_GTEST=OFF
  -DWITH_DEBUG_SYMBOLS=OFF
)

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  cmake_args+=(
    -DProtobuf_PROTOC_EXECUTABLE="${BUILD_PREFIX}/bin/protoc"
    -DPROTOBUF_PROTOC_EXECUTABLE="${BUILD_PREFIX}/bin/protoc"
  )
fi

cmake -S "${SRC_DIR}" -B build "${cmake_args[@]}"
# CMAKE_BUILD_PARALLEL_LEVEL allows capping parallelism (e.g. for local builds
# on memory-constrained machines); CI uses the full CPU_COUNT
cmake --build build --parallel "${CMAKE_BUILD_PARALLEL_LEVEL:-${CPU_COUNT:-2}}"
cmake --install build

# brpc unconditionally installs a static library next to the shared one;
# conda-forge packages should ship shared libraries only
rm -f "${PREFIX}/lib/libbrpc.a"
