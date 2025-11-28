#!/bin/bash
set -ex

cmake -S . -B _build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_Fortran_FLAGS="-I${PREFIX}/include" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    ${CMAKE_ARGS} \
    -DUSE_FFTW:BOOL=ON \
    -DUSE_MKL:BOOL=OFF \
    -DUSE_MKL_FFT:BOOL=OFF \
    -DUSE_OPENMP:BOOL=ON \
    -DUSE_VSL:BOOL=OFF \

cmake --build _build --parallel ${CPU_COUNT}

cmake --install _build --prefix $PREFIX
