#!/usr/bin/env bash

set -ex

which git

${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
    -S${SRC_DIR} \
    -Bbuild \
    -G"Ninja" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_Fortran_COMPILER=${FC} \
    -DCMAKE_Fortran_FLAGS="${FFLAGS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_OPENMP=OFF \
    -DENABLE_XHOST=OFF

cmake --build build --target install -j${CPU_COUNT}

# no independent tests


#if [ "$(uname)" == "Darwin" ]; then
#
#    # for FortranCInterface
#    CMAKE_Fortran_FLAGS="${FFLAGS} -L${CONDA_BUILD_SYSROOT}/usr/lib/system/ ${OPTS}"
#
#        -DENABLE_OPENMP=ON \
#        -DOpenMP_C_FLAG="-fopenmp=libiomp5" \
#fi
#if [ "$(uname)" == "Linux" ]; then
#
#        -DENABLE_OPENMP=ON \
#fi
