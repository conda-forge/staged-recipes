#!/bin/bash
set -ex

mkdir build
cd build

# select ARCH file and version
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then

    cmake .. \
        -DDMRG=ON \
        -DLINALG=Accelerate \
        -DBOOST_INCLUDE_DIR=${PREFIX}/include \
        -DCMAKE_INSTALL_PREFIX=${PREFIX}

else

    cmake .. \
        -DDMRG=ON \
        -DNEVPT2=ON \
        -DOPENMP=ON \
        -DMPI=ON \
        -DGA=ON \
        -DLINALG=Manual \
        -DLINALG_LIBRARIES="-lopenblas64_ -llapack" \
        -DCMAKE_INSTALL_PREFIX=${PREFIX}

    #  FC=mpif90 CC=mpicc CXX=mpicxx cmake    
    # cpp executable name harcoded in CMakeLists.txt
    ln -s $CPP ${PREFIX}/bin/cpp

        #-DLINALG=OpenBLAS \
        #-DOPENBLASROOT=$PREFIX \
fi


make

# Full test suite is taking too long
pymolcas verify .basic

make install
