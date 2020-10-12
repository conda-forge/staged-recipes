#!/usr/bin/env bash
set -ex

mkdir build
cd build

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_SBINDIR=bin
    -DENABLE_PYTHON=ON
    -DENABLE_CSHARP=OFF
    -DENABLE_TOOLS=ON
    -DBUILD_EXAMPLES=OFF
    -DENABLE_PACKAGING=OFF
    -DPython_EXECUTABLE=$PYTHON
    -DENABLE_DOC=OFF
    -DENABLE_LOG=OFF
    -DENABLE_EXCEPTIONS=ON
)

if [[ $target_platform == linux* ]] ; then
    cmake_config_args+=(
        -DCMAKE_CXX_STANDARD_LIBRARIES="-ludev"
        -DINSTALL_UDEV_RULES=ON
        -DUDEV_RULES_PATH=$PREFIX/lib/udev/rules.d
    )
else
    cmake_config_args+=(
        -DINSTALL_UDEV_RULES=OFF
        -DOSX_PACKAGE=OFF
    )
fi

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
