#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

cp -r all-sources/v4-client-cpp "${SRC_DIR}"

mkdir -p _conda-build-client  _conda-logs

pushd _conda-build-client
  cmake "${SRC_DIR}"/v4-client-cpp \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_SHARED_LIBS=ON \
    -G Ninja
#    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
    # > "${SRC_DIR}"/_conda-logs/_cmake_configure-client.log 2>&1

  cmake --build . --target dydx_v4_client_lib -- -j"${CPU_COUNT}"
  cmake --install . --component client
popd

pushd _conda-build-client
  cmake --build . --target dydx_v4_client_lib_tests -- -j"${CPU_COUNT}"
  lib/dydx_v4_client_lib_tests
  mkdir -p "${SRC_DIR}"/tests
  cp lib/dydx_v4_client_lib_tests "${SRC_DIR}"/tests
popd
