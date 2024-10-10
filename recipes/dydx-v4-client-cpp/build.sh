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
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
    -G Ninja
    # > "${SRC_DIR}"/_conda-logs/_cmake_configure-client.log 2>&1

  cmake --build . --target dydx_v4_client_lib -- -j"${CPU_COUNT}"
  cmake --install . --component client
popd

pushd _conda-build-client
  cmake --build . --target dydx_v4_client_lib_tests -- -j"${CPU_COUNT}"
  lib/dydx_v4_client_lib_tests
  cp lib/dydx_v4_client_lib_tests "${PREFIX}"/bin
  chmod 755 "${PREFIX}"/bin/dydx_v4_client_lib_tests
popd
