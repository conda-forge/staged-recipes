#!/bin/bash

set -e

# the files were installed here during the build - now we shall copy them
# to the right spot
COPY_PREFIX=${SRC_DIR}/install_prefix_conda

GFORTRAN_VERSION=7.3.0

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/gcc/${chost}/${GFORTRAN_VERSION}
mkdir -p ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}

cp ${COPY_PREFIX}/bin/gfortran ${PREFIX}/bin/.
cp ${COPY_PREFIX}/bin/${chost}-gfortran ${PREFIX}/bin/.

cp ${COPY_PREFIX}/libexec/gcc/${chost}/${GFORTRAN_VERSION}/collect2 ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.
cp ${COPY_PREFIX}/libexec/gcc/${chost}/${GFORTRAN_VERSION}/f951 ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.
cp ${COPY_PREFIX}/libexec/gcc/${chost}/${GFORTRAN_VERSION}/lto-wrapper ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.

cp ${COPY_PREFIX}/lib/libgfortran.spec ${PREFIX}/lib/.

# For -fopenmp:
p ${COPY_PREFIX}/lib/libgomp.spec ${PREFIX}/lib/.

# For -ffast-math
cp ${COPY_PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/crtfastmath.o ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.

# For -static:
cp ${COPY_PREFIX}/lib/libgfortran.a ${PREFIX}/lib/.
cp ${COPY_PREFIX}/lib/libgomp.a ${PREFIX}/lib/.

cp ${COPY_PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/libgcc.a ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.
cp ${COPY_PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/libgcc_eh.a ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.

cp -r ${COPY_PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/finclude ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.

# include{,-fixed} may not be needed unless -fopenmp is passed (not sure on that):
cp -r ${COPY_PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/include-fixed ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.
cp -r ${COPY_PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/include ${PREFIX}/lib/gcc/${chost}/${GFORTRAN_VERSION}/.

# Stub libraries:
cp ${COPY_PREFIX}/lib/libgcc_ext.10.4.dylib ${PREFIX}/lib/.
cp ${COPY_PREFIX}/lib/libgcc_ext.10.5.dylib ${PREFIX}/lib/.
