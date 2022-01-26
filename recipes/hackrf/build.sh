#!/usr/bin/env bash

set -ex

cd host

mkdir build
cd build

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_SUFFIX=""
    -DINSTALL_UDEV_RULES=ON
    -DUDEV_RULES_GROUP=plugdev
    -DUDEV_RULES_PATH=$PREFIX/lib/udev/rules.d
)

cmake ${CMAKE_ARGS} -G "Ninja" .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
