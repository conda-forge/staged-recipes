#!/usr/bin/env bash

set -euo pipefail

if [[ "${target_platform}" == "osx-64" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS:-} -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 -DCMAKE_OSX_ARCHITECTURES=x86_64"
fi

if [[ "${target_platform}" == "osx-arm64" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS:-} -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_OSX_ARCHITECTURES=arm64"
fi

sed -i 's/install(TARGETS mgclient-static mgclient-shared/install(TARGETS mgclient-shared/' "${SRC_DIR}"/src/CMakeLists.txt
mkdir -p "${SRC_DIR}"/build
pushd "${SRC_DIR}"/build
  cmake ${CMAKE_ARGS} .. -G "Ninja"
  cmake --build .
  ninja install
popd

if [[ "${target_platform}" != "osx-"* ]] && [[ "${target_platform}" != "linux-"* ]]; then
  # Oddly, cmake install the dll in 'lib'
  mv "${PREFIX}"/Library/lib/mgclient.dll ${PREFIX}/Library/bin/mgclient.dll
fi

# The static library .lib conflicts with the dynamic on non-linux platforms,
# and the tests depend on static library
if [[ "${target_platform}" == "linux-"* ]]; then
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