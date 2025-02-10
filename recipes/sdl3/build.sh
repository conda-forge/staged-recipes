#!/bin/sh

if [[ ${HOST} =~ .*darwin.* ]]; then
      export CFLAGS="${CFLAGS} -isysroot ${SDKROOT:-$CONDA_BUILD_SYSROOT}"

    if [[ "${target_platform}" == "osx-arm64" ]]; then
      export ADDITIONAL_OPTIONS="-DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.3"
    fi

    if [[ "${target_platform}" == "osx-x86_64" ]]; then
      export ADDITIONAL_OPTIONS="-DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13"
    fi
fi

mkdir build
cd build

cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DSDL_AUDIO=OFF \
      -DSDL_CAMERA=OFF \
      -DSDL_JOYSTICK=OFF \
      -DSDL_HAPTIC=OFF \
      -DSDL_HIDAPI=OFF \
      -DSDL_POWER=OFF \
      -DSDL_SENSOR=OFF \
      -DSDL_DIALOG=OFF

make
make install
