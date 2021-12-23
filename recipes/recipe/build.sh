#!/bin/bash
set -ex

mkdir build
cd build

# select ARCH file and version
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then

    cmake .. \
        -DLINALG=Accelerate \
        -CMAKE_INSTALL_PREFIX=${PREFIX}

else

    cmake .. \
        -DLINALG=OpenBLAS \
        -DOPENBLASROOT=$PREFIX \
        -CMAKE_INSTALL_PREFIX=${PREFIX}
fi


make

# Full test suite is taking too long
pymolcas verify .basic

make install
