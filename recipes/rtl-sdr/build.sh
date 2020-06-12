#!/usr/bin/env bash

set -ex

mkdir build
cd build

# configuration
# change -DLIB_INSTALL_DIR=lib to -DCMAKE_INSTALL_LIBDIR=lib for release after 0.6
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_INSTALL_DIR=lib
    -DDETACH_KERNEL_DRIVER=OFF
    -DENABLE_ZEROCOPY=OFF
    -DINSTALL_UDEV_RULES=OFF
)

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
