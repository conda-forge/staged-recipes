#!/usr/bin/env bash

set -euo pipefail

mkdir -p "${SRC_DIR}"/build
pushd "${SRC_DIR}"/build
  cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    .. -G "Ninja"
  ninja install
popd

rm -f ${PREFIX}/lib/libmgclient.a

pushd "${SRC_DIR}"/build
  cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
    -DBUILD_TESTING=ON \
    .. -G "Ninja"

  cmake --build . --target value \
      encoder \
      decoder \
      client \
      transport \
      allocator \
      unit_mgclient_value
   ctest || true
   # 3 tests fails due to lack of memgraph docker container
popd
