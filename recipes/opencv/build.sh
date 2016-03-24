#!/bin/bash
mkdir build
cd build


if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  DYNAMIC_EXT="so"
  TBB=""
  OPENMP="-DWITH_OPENMP=1"
  IS_OSX=0
fi
if [ "$(uname -s)" == "Darwin" ]; then
  IS_OSX=1
  DYNAMIC_EXT="dylib"
  OPENMP=""
  TBB="-DWITH_TBB=1 -DTBB_LIB_DIR=$PREFIX/lib -DTBB_INCLUDE_DIRS=$PREFIX/include -DTBB_STDDEF_PATH=$PREFIX/include/tbb/tbb_stddef.h"
fi

cmake ..                                                                 \
    $TBB                                                                 \
    $OPENMP                                                              \
    -DCMAKE_SKIP_RPATH=1                                                 \
    -DWITH_EIGEN=1                                                       \
    -DBUILD_opencv_apps=0                                                \
    -DBUILD_TESTS=0                                                      \
    -DBUILD_DOCS=0                                                       \
    -DBUILD_PERF_TESTS=0                                                 \
    -DBUILD_ZLIB=1                                                       \
    -DBUILD_TIFF=1                                                       \
    -DBUILD_PNG=1                                                        \
    -DBUILD_OPENEXR=1                                                    \
    -DBUILD_JASPER=1                                                     \
    -DBUILD_JPEG=1                                                       \
    -DPYTHON_EXECUTABLE=$PREFIX/bin/python${PY_VER}                      \
    -DPYTHON_INCLUDE_PATH=$PREFIX/include/python${PY_VER}                \
    -DPYTHON_LIBRARY=$PREFIX/lib/libpython${PY_VER}.$DYNAMIC_EXT         \
    -DPYTHON_PACKAGES_PATH=$SP_DIR                                       \
    -DWITH_CUDA=0                                                        \
    -DWITH_OPENCL=0                                                      \
    -DWITH_OPENNI=0                                                      \
    -DWITH_FFMPEG=0                                                      \
    -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j${CPU_COUNT}
make install

