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
  cmake --build .
  ninja install
popd

# The static library .lib conflicts with the dynamic on non-unix platforms,
# and the tests depend on static library
if [[ "${target_platform}" == "osx-"* ]] || [[ "${target_platform}" == "linux-"* ]]; then
  find ${PREFIX} -name libmgclient.a -exec rm -f {} \;

  pushd "${SRC_DIR}"/build
    cmake ${CMAKE_ARGS} \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
      -DBUILD_TESTING=ON \
      .. -G "Ninja"
    cmake --build .
    # 3 tests fail due to lack of memgraph server
    ctest --output-on-failure || true
  popd
fi