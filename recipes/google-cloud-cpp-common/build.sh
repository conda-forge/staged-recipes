#!/bin/bash

set -euo pipefail

mkdir build_cmake
pushd build_cmake

export OPENSSL_ROOT_DIR=$PREFIX

cmake -GNinja \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    ..

ninja install

popd
