#!/usr/bin/env bash

set -euo pipefail

if [[ "${target_platform}" == "osx-64" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS:-}"
fi

if [[ "${target_platform}" == "osx-arm64" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS:-}"
fi

mkdir -p "${SRC_DIR}"/build
pushd "${SRC_DIR}"/build
  cmake ${CMAKE_ARGS} .. -G "Ninja"
  ninja install
popd

find ${PREFIX} -name libmgclient.a -exec rm -f {} \;

pushd "${SRC_DIR}"/build
  cmake ${CMAKE_ARGS} \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
    -DBUILD_TESTING=ON \
    .. -G "Ninja"
  cmake --build .
popd
