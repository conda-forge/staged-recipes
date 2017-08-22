#!/bin/sh

mkdir build
cd build

# EXAMPLES_ENABLE=1 enables tests to be run (requires Python)

if [ $(uname -s) == 'Darwin' ]; then
    OSX_RPATH=1
    WITH_OPENMP=0  # CMake script fails to setup OpenMP_C_FLAGS anyway 
else
    OSX_RPATH=0
    WITH_OPENMP=1
fi

cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
    -DEXAMPLES_ENABLE=ON \
    -DEXAMPLES_INSTALL=OFF \
    -DOPENMP_ENABLE=$WITH_OPENMP \
    -DLAPACK_ENABLE=ON \
    -DLAPACK_LIBRARIES=$PREFIX/lib/libopenblas${SHLIB_EXT} \
    -DCMAKE_MACOSX_RPATH=$OSX_RPATH \
    -DKLU_ENABLE=ON \
    -DKLU_LIBRARY_DIR=${PREFIX}/lib \
    ..

make install -j${CPU_COUNT}
