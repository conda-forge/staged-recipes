#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

cp -r all-sources/v4-client-cpp "${SRC_DIR}"

mkdir -p _conda-build-protocol  _conda-logs

pushd _conda-build-protocol
  cmake "${SRC_DIR}"/v4-client-cpp \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
    -G Ninja > "${SRC_DIR}"/_conda-logs/_cmake_configure-protocol.log 2>&1

  cmake --build . --target dydx_v4_proto -- -j"${CPU_COUNT}" > "${SRC_DIR}"/_conda-logs/_cmake_build-protocol.log 2>&1
  cmake --install . --component protocol
popd

rm -rf "${PREFIX}"/lib/libdydx_v4_proto.so
rm -rf "${PREFIX}"/lib/libdydx_v4_proto.dylib
rm -rf "${PREFIX}"/lib/pkgconfig/dydx_v4_proto.pc
rm -rf "${PREFIX}"/lib/cmake/dydx_v4_proto/dydx_v4_proto-config.cmake

rm -rf "${PREFIX}"/lib/libdydx_v4_proto.so.*
rm -rf "${PREFIX}"/lib/libdydx_v4_proto.*
rm -rf "${PREFIX}"/lib/libdydx_v4_proto.so.*
rm -rf "${PREFIX}"/lib/libdydx_v4_proto.*
