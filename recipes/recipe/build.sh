#!/bin/bash
set -ex

mkdir build
cd build

# select ARCH file and version
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then

    cmake .. \
        -DLINALG=Accelerate \
        -DCMAKE_INSTALL_PREFIX=${PREFIX}

else

    cmake .. \
        -DLINALG=Manual \
        -DLINALG_LIBRARIES="-lopenblas64_ -llapack" \
        -DCMAKE_INSTALL_PREFIX=${PREFIX}

        #-DLINALG=OpenBLAS \
        #-DOPENBLASROOT=$PREFIX \
fi


make

# Full test suite is taking too long
pymolcas verify .basic

make install
