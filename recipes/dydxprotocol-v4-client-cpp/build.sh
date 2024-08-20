#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

cp -r all-sources/v4-client-cpp "${SRC_DIR}"

mkdir -p _conda-build-protocol _conda-build-client  _conda-logs

patch -p0 < "${RECIPE_DIR}"/patches/xxxx-cmake-protocol-lib.patch

pushd _conda-build-protocol
  cmake "${SRC_DIR}"/v4-client-cpp \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
    -G Ninja > "${SRC_DIR}"/_conda-logs/_cmake_configure-protocol.log 2>&1

  cmake --build . --target dydx_v4_proto -- -j"${CPU_COUNT}"
  cmake --install . --component protocol
popd

patch -p0 < "${RECIPE_DIR}"/patches/xxxx-cmake-client-lib.patch
pushd _conda-build-client
  cmake "${SRC_DIR}"/v4-client-cpp \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
    -G Ninja > "${SRC_DIR}"/_conda-logs/_cmake_configure-client.log 2>&1

  cmake --build . --target dydx_v4_client_lib -- -j"${CPU_COUNT}"
  cmake --install . --component client
popd

pushd _conda-build-protocol
  cmake --build . --target dydx_v4_client_lib_static -- -j"${CPU_COUNT}"
popd

pushd _conda-build-client
  cp "${SRC_DIR}"/_conda-build-protocol/lib/libdydx_v4_client_lib_static.a lib/proto
  cmake --build . --target dydx_v4_client_lib_tests -- -j"${CPU_COUNT}"
  lib/dydx_v4_client_lib_tests
  cp lib/dydx_v4_client_lib_tests "${SRC_DIR}"
  chmod 755 "${SRC_DIR}"/dydx_v4_client_lib_tests
popd
