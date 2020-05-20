#!/bin/bash

set -ex

mkdir build
cd build

# enable components explicitly so we get build error when unsatisfied
#  WITH_LOCAL_CONFIG requires libini
#  WITH_SERIAL_BACKEND requires libserialport
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_SBINDIR=bin
    -DCSHARP_BINDINGS=OFF
    -DENABLE_PACKAGING=OFF
    -DPYTHON_BINDINGS=OFF
    -DWITH_DOC=OFF
    -DWITH_EXAMPLES=OFF
    -DWITH_MAN=OFF
    -DWITH_NETWORK_BACKEND=ON
    -DWITH_SERIAL_BACKEND=OFF
    -DWITH_TESTS=ON
    -DWITH_USB_BACKEND=ON
    -DWITH_XML_BACKEND=ON
)

if [[ $target_platform == linux* ]] ; then
    cmake_config_args+=(
        -DINSTALL_UDEV_RULE=ON
        -DUDEV_RULES_INSTALL_DIR=$PREFIX/lib/udev/rules.d
        -DWITH_IIOD=ON
        -DWITH_LOCAL_BACKEND=ON
        -DWITH_LOCAL_CONFIG=OFF
        -DWITH_SYSTEMD=OFF
        -DWITH_SYSVINIT=OFF
        -DWITH_UPSTART=OFF
    )
else
    cmake_config_args+=(
        -DOSX_INSTALL_FRAMEWORKSDIR=$PREFIX/Library/Frameworks
        -DOSX_PACKAGE=OFF
        -DWITH_IIOD=OFF
        -DWITH_LOCAL_BACKEND=OFF
    )
fi

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
