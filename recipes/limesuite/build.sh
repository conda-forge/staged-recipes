#!/usr/bin/env bash

set -ex

mkdir forgebuild
cd forgebuild

# enable components explicitly so we get build error when unsatisfied
cmake_config_args=(
    -DBUILD_SHARED_LIBS=ON
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_SUFFIX=""
    -DLIME_SUITE_EXTVER="condaforge"
    -DENABLE_API_DOXYGEN=OFF
    -DENABLE_BACKEND_CYAPI=OFF
    -DENABLE_BACKEND_LIBUSB=ON
    -DENABLE_DESKTOP=OFF
    -DENABLE_EVB7COM=OFF
    -DENABLE_EXAMPLES=OFF
    -DENABLE_FTDI=ON
    -DENABLE_FX3=ON
    -DENABLE_HEADERS=ON
    -DENABLE_LIBRARY=ON
    -DENABLE_LIMERFE=ON
    -DENABLE_LIME_UTIL=ON
    -DENABLE_MCU_TESTBENCH=OFF
    -DENABLE_OCTAVE=OFF
    -DENABLE_PCIE_XILLYBUS=ON
    -DENABLE_QUICKTEST=OFF
    -DENABLE_REMOTE=OFF
    -DENABLE_SIMD_FLAGS="none"
    -DENABLE_SOAPY_LMS7=ON
    -DENABLE_SPI=OFF
    -DENABLE_STREAM_UNITE=OFF
    -DENABLE_UTILITIES=OFF
)

if [[ $target_platform == linux* ]] ; then
    cmake_config_args+=(
        -DENABLE_GUI=ON
        -DUDEV_RULES_PATH=$PREFIX/lib/udev/rules.d
    )
else
    cmake_config_args+=(
        -DENABLE_GUI=OFF
    )
fi

cmake -G "Ninja" .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
