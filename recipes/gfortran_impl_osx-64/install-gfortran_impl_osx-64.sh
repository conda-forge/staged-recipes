#!/bin/bash

set -e

# the files were installed here during the build - now we shall copy them
# to the right spot
COPY_PREFIX=${SRC_DIR}/install_prefix_conda

GFORTRAN_VERSION=7.3.0

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/gcc/${macos_machine}/${GFORTRAN_VERSION}
mkdir -p ${PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}

cp ${COPY_PREFIX}/bin/gfortran ${PREFIX}/bin/.
cp ${COPY_PREFIX}/bin/${macos_machine}-gfortran ${PREFIX}/bin/.

cp ${COPY_PREFIX}/libexec/gcc/${macos_machine}/${GFORTRAN_VERSION}/collect2 ${PREFIX}/libexec/gcc/${macos_machine}/${GFORTRAN_VERSION}/.
cp ${COPY_PREFIX}/libexec/gcc/${macos_machine}/${GFORTRAN_VERSION}/f951 ${PREFIX}/libexec/gcc/${macos_machine}/${GFORTRAN_VERSION}/.
cp ${COPY_PREFIX}/libexec/gcc/${macos_machine}/${GFORTRAN_VERSION}/lto-wrapper ${PREFIX}/libexec/gcc/${macos_machine}/${GFORTRAN_VERSION}/.

cp ${COPY_PREFIX}/lib/libgfortran.spec ${PREFIX}/lib/.

# For -fopenmp:
cp ${COPY_PREFIX}/lib/libgomp.spec ${PREFIX}/lib/.

# For -ffast-math
cp ${COPY_PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/crtfastmath.o ${PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/.

# For -static:
cp ${COPY_PREFIX}/lib/libgfortran.a ${PREFIX}/lib/.
cp ${COPY_PREFIX}/lib/libgomp.a ${PREFIX}/lib/.

cp ${COPY_PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/libgcc.a ${PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/.
cp ${COPY_PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/libgcc_eh.a ${PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/.

cp -r ${COPY_PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/finclude ${PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/.

# include{,-fixed} may not be needed unless -fopenmp is passed (not sure on that):
cp -r ${COPY_PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/include-fixed ${PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/.
cp -r ${COPY_PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/include ${PREFIX}/lib/gcc/${macos_machine}/${GFORTRAN_VERSION}/.

# Stub libraries:
cp ${COPY_PREFIX}/lib/libgcc_ext.10.4.dylib ${PREFIX}/lib/.
cp ${COPY_PREFIX}/lib/libgcc_ext.10.5.dylib ${PREFIX}/lib/.
