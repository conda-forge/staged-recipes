#!/usr/bin/env bash

set -ex

cmake -E make_directory buildconda
cd buildconda

# enable components explicitly so we get build error when unsatisfied
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_SUFFIX=""
    -DENABLE_DOXYGEN=OFF
    -DENABLE_TESTING=ON
    -DLIBHIDAPI_INCLUDE_DIR=$PREFIX/include/hidapi
    -DLIBHIDAPI_LIBRARIES=$PREFIX/lib/libhidapi-libusb$SHLIB_EXT
    -DLIBUSB_INCLUDE_DIR=$PREFIX/include/libusb-1.0
    -DLIBUSB_LIBRARIES=$PREFIX/lib/libusb-1.0$SHLIB_EXT
)

cmake ${CMAKE_ARGS} -G "Ninja" .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install

if [[ $target_platform == linux-* ]]; then
    mkdir -p $PREFIX/lib/udev/rules.d/
    cp ../50-funcube.rules $PREFIX/lib/udev/rules.d/
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --build-config Release --output-on-failure --timeout 120 -j${CPU_COUNT}
fi
