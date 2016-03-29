#!/bin/bash

mkdir build
cd build

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  DYNAMIC_EXT="so"
  OPENMP="-DWITH_OPENMP=1"
fi
if [ "$(uname -s)" == "Darwin" ]; then
  DYNAMIC_EXT="dylib"
  OPENMP=""
fi

cmake -LAH ..                                                            \
    $OPENMP                                                              \
    -DCMAKE_SKIP_RPATH=1                                                 \
    -DWITH_EIGEN=1                                                       \
    -DBUILD_opencv_apps=0                                                \
    -DBUILD_TESTS=0                                                      \
    -DBUILD_DOCS=0                                                       \
    -DBUILD_PERF_TESTS=0                                                 \
    -DBUILD_ZLIB=0                                                       \
    -DZLIB_LIBRARY=$PREFIX/lib/libz.$DYNAMIC_EXT                         \
    -DBUILD_TIFF=0                                                       \
    -DBUILD_PNG=0                                                        \
    -DBUILD_OPENEXR=1                                                    \
    -DBUILD_JASPER=1                                                     \
    -DBUILD_JPEG=0                                                       \
    -DPYTHON_EXECUTABLE=$PREFIX/bin/python${PY_VER}                      \
    -DPYTHON_INCLUDE_PATH=$PREFIX/include/python${PY_VER}                \
    -DPYTHON_LIBRARY=$PREFIX/lib/libpython${PY_VER}.$DYNAMIC_EXT         \
    -DPYTHON_PACKAGES_PATH=$SP_DIR                                       \
    -DWITH_CUDA=0                                                        \
    -DWITH_OPENCL=0                                                      \
    -DWITH_OPENNI=0                                                      \
    -DWITH_FFMPEG=0                                                      \
    -DCMAKE_INSTALL_PREFIX=$PREFIX

make
make install

