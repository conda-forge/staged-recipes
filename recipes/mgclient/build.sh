#!/usr/bin/env bash

set -euo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
  export CMAKE_OSX_ARCHITECTURES="arm64"
elif [[ "${target_platform}" == "osx-"* ]] || [[ "${target_platform}" == "linux-"* ]]; then
  export INSTALL_PREFIX="${PREFIX}"
else
  export INSTALL_PREFIX="${PREFIX}/Library"
fi

mkdir -p "${SRC_DIR}"/build
pushd "${SRC_DIR}"/build
  cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
    -DBUILD_TESTING=ON \
    .. -G "Ninja"
  ninja install
popd

rm -f ${INSTALL_PREFIX}/lib/libmgclient.a

# pushd "${SRC_DIR}"/build
#   cmake -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_INSTALL_PREFIX="${SRC_DIR}/_conda_test" \
#     .. -G "Ninja"
#
#   cmake --build . --target value \
#       encoder \
#       decoder \
#       client \
#       transport \
#       allocator \
#       unit_mgclient_value
#    ctest || true
#    # 3 tests fails due to lack of memgraph docker
# popd
