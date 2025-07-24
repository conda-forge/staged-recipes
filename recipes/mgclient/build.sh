#!/usr/bin/env bash

set -euo pipefail

mkdir -p "${SRC_DIR}"/build
pushd "${SRC_DIR}"/build
  cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -Dmgclient_BUILD_TESTS=OFF \
    -Dmgclient_BUILD_EXAMPLES=OFF \
    -Dmgclient_BUILD_SHARED_LIBS=ON \
    .. -G "Ninja"

  ninja install
popd
