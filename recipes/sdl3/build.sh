#!/bin/sh

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
