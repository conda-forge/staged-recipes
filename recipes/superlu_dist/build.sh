#!/usr/bin/env bash

export CFLAGS="$CFLAGS -std=c99 -fPIC"

WORK=$PWD
# run full build & install twice, once for static, once for shared
# because it's the cmake way
for shared in OFF ON; do
    cd "$WORK"
    mkdir build_$shared
    cd build_$shared
    # enable_blaslib=OFF so OpenBLAS will be found instead of the built-in BLAS

    # build & install once for static
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
        -DCMAKE_C_FLAGS="${CFLAGS}" \
        -DCMAKE_C_COMPILER=mpicc \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DTPL_PARMETIS_INCLUDE_DIRS="${PREFIX}/include" \
        -DTPL_PARMETIS_LIBRARIES="${PREFIX}/lib/libparmetis${SHLIB_EXT};${PREFIX}/lib/libmetis${SHLIB_EXT}" \
        -DTPL_BLAS_LIBRARIES="${PREFIX}/lib/libblas${SHLIB_EXT}" \
        -DTPL_LAPACK_LIBRARIES="${PREFIX}/lib/liblapack${SHLIB_EXT};${PREFIX}/lib/libblas${SHLIB_EXT}" \
        -Denable_blaslib=OFF \
        -Denable_tests=ON \
        -Denable_doc=OFF \
        -DBUILD_SHARED_LIBS=$shared

    make -j${CPU_COUNT}
    # ctest seems to have weird PATH assumptions
    export PATH=$PWD/EXAMPLE:$PWD/TEST:$PATH
    ctest
    make install
done
