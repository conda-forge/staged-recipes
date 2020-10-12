#!/usr/bin/env bash
set -ex

mkdir build
cd build

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_SBINDIR=bin
    -DBUILD_PYTHON=ON
    -DBUILD_CLI=ON
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
    -DENABLE_PACKAGING=OFF
    -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON
    -DWITH_DOC=OFF
)

if [[ $target_platform == linux* ]] ; then
    cmake_config_args+=(
        -DCMAKE_CXX_STANDARD_LIBRARIES="-ludev"
        -DUDEV_RULES_PATH=$PREFIX/lib/udev/rules.d
        -DINSTALL_UDEV_RULES=ON
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
