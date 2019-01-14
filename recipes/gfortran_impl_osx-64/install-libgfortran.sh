#!/bin/bash

set -e

mkdir -p ${PREFIX}/lib

LIBGFORTRAN_VERSION=4
LIBQUADMATH_VERSION=0
LIBGCC_S_VERSION=1

cp ${BUILD_PREFIX}/lib/libgfortran.dylib ${PREFIX}/lib/.
cp ${BUILD_PREFIX}/lib/libgfortran.${LIBGFORTRAN_VERSION}.dylib ${PREFIX}/lib/.
cp ${BUILD_PREFIX}/lib/libgomp.dylib ${PREFIX}/lib/.
cp ${BUILD_PREFIX}/lib/libgomp.${LIBGCC_S_VERSION}.dylib ${PREFIX}/lib/.

# Including libquadmath for the time
# being. This will need to be broken
# out in the long term.
cp ${BUILD_PREFIX}/lib/libquadmath.dylib ${PREFIX}/lib/.
cp ${BUILD_PREFIX}/lib/libquadmath.${LIBQUADMATH_VERSION}.dylib ${PREFIX}/lib/.

# Including libgcc_s for the time
# being. This will need to be broken
# out in the long term.
cp ${BUILD_PREFIX}/lib/libgcc_s.${LIBGCC_S_VERSION}.dylib ${PREFIX}/lib/.
cp ${BUILD_PREFIX}/lib/libgcc_s_ppc64.${LIBGCC_S_VERSION}.dylib ${PREFIX}/lib/.
cp ${BUILD_PREFIX}/lib/libgcc_s_x86_64.${LIBGCC_S_VERSION}.dylib ${PREFIX}/lib/.
