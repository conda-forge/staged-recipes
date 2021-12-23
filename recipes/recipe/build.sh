#!/bin/bash
set -ex

mkdir build
cd build

# select ARCH file and version
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then

    cmake .. \
        -DLINALG=Accelerate

else

    cmake .. \
        -DLINALG=OpenBLAS \
        -DOPENBLASROOT=$PREFIX
fi


make

# Full test suite is taking too long
pymolcas verify .basic
