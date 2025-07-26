#!/usr/bin/env bash

set -euo pipefail

if [[ "${target_platform}" == "osx-64" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS:-} -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15"
fi

if [[ "${target_platform}" == "osx-arm64" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS:-} -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_OSX_ARCHITECTURES=arm64"
fi

mkdir -p "${SRC_DIR}"/build
pushd "${SRC_DIR}"/build
  cmake ${CMAKE_ARGS} .. -G "Ninja"
  cmake --build .
  sed -i 's/install(TARGETS mgclient-static mgclient-shared/install(TARGETS mgclient-static/' src/CMakeLists.txt
  ninja install
popd

# The static library .lib conflicts with the dynamic on non-unix platforms,
# and the tests depend on static library
if [[ "${target_platform}" == "osx-"* ]] || [[ "${target_platform}" == "linux-"* ]]; then
  pushd "${SRC_DIR}"/build
    cmake ${CMAKE_ARGS} \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
      -DBUILD_TESTING=ON \
      .. -G "Ninja"
    cmake --build .
    # 3 tests fail due to lack of memgraph server
    ctest --output-on-failure || true
  popd
fi