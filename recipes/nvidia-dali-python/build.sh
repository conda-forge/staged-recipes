#!/bin/bash

mkdir -p third_party/boost/preprocessor/include
ln -sf $PREFIX/include/boost third_party/boost/preprocessor/include

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
  -DBUILD_PYTHON=ON \
  -DBUILD_FFTS=OFF \
  -DBUILD_CVCUDA=OFF \
  -DBUILD_JPEG_TURBO=ON \
  -DBUILD_LIBTIFF=ON \
  -DBUILD_CFITSIO=ON \
  -DBUILD_DALI_NODEPS=ON \
  ..

make -j${CPU_COUNT}
make install
