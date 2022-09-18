#!/bin/bash

set -ex

if [[ "${PKG_NAME}" = "adbc-driver-manager-cpp" ]]; then
    export PKG_ROOT=c/driver_manager
elif [[ "${PKG_NAME}" = "adbc-driver-postgresql-cpp" ]]; then
    export PKG_ROOT=c/driver/postgresql
elif [[ "${PKG_NAME}" = "adbc-driver-sqlite-cpp" ]]; then
    export PKG_ROOT=c/driver/sqlite
else
    echo "Unknown package ${PKG_NAME}"
    exit 1
fi

mkdir -p "build-cpp/${PKG_NAME}"
pushd "build-cpp/${PKG_NAME}"

cmake ../../${PKG_ROOT} \
      -G Ninja \
      -DADBC_BUILD_SHARED=ON \
      -DADBC_BUILD_STATIC=OFF \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX

cmake --build . --target install -j

popd
