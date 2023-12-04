#!/usr/bin/env bash

set -ex

mkdir build
cd build

if [[ "$target_platform" == linux-64 ]]; then
  # need some additional defines to work around old kernel
  export CFLAGS="$CFLAGS -DHIDAPI_ALLOW_BUILD_WORKAROUND_KERNEL_2_6_39 -DBUS_SPI=0x1C"
fi

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
)

cmake ${CMAKE_ARGS} -G "Ninja" .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
