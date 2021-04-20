#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DLIB_SUFFIX="" \
      -DFTDI_EEPROM=OFF \
      -DSTATICLIBS=OFF \
      -DEXAMPLES=OFF

cmake --build . --config Release
cmake --build . --config Release --target install
