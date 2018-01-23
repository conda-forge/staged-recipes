#!/usr/bin/env bash

mkdir build
cd build

# enable_blaslib=OFF so OpenBLAS will be found instead of the built-in BLAS

cmake .. \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
    -DCMAKE_C_FLAGS="${CFLAGS} -std=c99 -fPIC" \
    -DCMAKE_C_COMPILER=mpicc \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DBUILD_SHARED_LIBS=ON \
    -DTPL_PARMETIS_INCLUDE_DIRS=${PREFIX}/include \
    -DTPL_PARMETIS_LIBRARIES="${PREFIX}/lib/libparmetis${SHLIB_EXT};${PREFIX}/lib/libmetis${SHLIB_EXT}" \
    -Denable_blaslib=OFF \
    -Denable_tests=ON \
    -Denable_doc=OFF

make -j${CPU_COUNT}
# ctest seems to have weird PATH assumptions
export PATH=$PWD/EXAMPLE:$PWD/TEST:$PATH
ctest
make install

# run again to get static
