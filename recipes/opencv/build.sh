#!/bin/bash

mkdir build
cd build

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  DYNAMIC_EXT="so"
  TBB=""
  OPENMP="-DWITH_OPENMP=1"
fi
if [ "$(uname -s)" == "Darwin" ]; then
  DYNAMIC_EXT="dylib"
  OPENMP=""
  TBB="-DWITH_TBB=1 -DTBB_LIB_DIR=$PREFIX/lib -DTBB_INCLUDE_DIRS=$PREFIX/include -DTBB_STDDEF_PATH=$PREFIX/include/tbb/tbb_stddef.h"
fi

cmake -LAH ..                                                            \
    $TBB                                                                 \
    $OPENMP                                                              \
    -DCMAKE_SKIP_RPATH=1                                                 \
    -DWITH_EIGEN=1                                                       \
    -DBUILD_opencv_apps=0                                                \
    -DBUILD_TESTS=1                                                      \
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

# Before installing - ensure that tests run. First things first,
# download the test data:
#curl -L -o test_data.tar.gz https://github.com/Itseez/opencv_extra/archive/$PKG_VERSION.tar.gz
cp $RECIPE_DIR/test_data.tar.gz ./test_data.tar.gz
tar -xvf test_data.tar.gz opencv_extra-$PKG_VERSION/testdata
export OPENCV_TEST_DATA_PATH=$SRC_DIR/build/opencv_extra-$PKG_VERSION/testdata 

# This is before the RPATH has been rectified by conda - so
# we shim it here using LD_LIBRARY_PATH on Linux and
# DYLD_LIBRARY_PATH on OSX.
if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SRC_DIR/build/lib $PYTHON ../modules/ts/misc/run.py -a $SRC_DIR/build
fi
if [ "$(uname -s)" == "Darwin" ]; then
    DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$SRC_DIR/build/lib $PYTHON ../modules/ts/misc/run.py -a $SRC_DIR/build
fi

make install
