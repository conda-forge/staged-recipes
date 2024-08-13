#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

# C++ client
pushd v4-client-cpp
  mkdir -p _conda-build
  pushd _conda-build
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH="${PREFIX}/lib" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
      -G Ninja > _cmake_configure.log 2>&1

    cmake --build . --target dydx_v4_client_lib -- -j"${CPU_COUNT}"
    cmake --build . --target dydx_v4_client_lib_tests -- -j"${CPU_COUNT}"
    lib/dydx_v4_client_lib_tests
    cp lib/dydx_v4_client_lib_tests "${SRC_DIR}"
    chmod 755 "${SRC_DIR}"/dydx_v4_client_lib_tests
    cmake --install .
  popd
popd
