#!/bin/bash

mkdir -p third_party/boost/preprocessor/include
ln -sf $PREFIX/include/boost third_party/boost/preprocessor/include/

mkdir -p third_party/dlpack/include/
ln -sf $PREFIX/include/dlpack third_party/dlpack/include/

export CXXFLAGS="$CXXFLAGS -isystem $PREFIX/include/opencv4"

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
  -DBUILD_PYTHON=ON \
  -DBUILD_FFTS=OFF \
  -DBUILD_CVCUDA=OFF \
  -DBUILD_JPEG_TURBO=ON \
  -DBUILD_LIBTIFF=ON \
  -DBUILD_CFITSIO=ON \
  -DBUILD_BENCHMARK=OFF \
  -DBUILD_TEST=OFF \
  -DBUILD_OPENCV=ON \
  -DBUILD_LMDB=OFF \
  -DBUILD_LIBSND=OFF \
  -DBUILD_LIBTAR=OFF \
  -DBUILD_FFMPEG=OFF \
  -DBUILD_NVDEC=OFF \
  -DBUILD_NVIMAGECODEC=OFF \
  -DBUILD_NVML=OFF \
  ..

make -j${CPU_COUNT}
make install
