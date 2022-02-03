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
        -DLINALG=Manual \
        -DLINALG_LIBRARIES="-lopenblas64_ -llapack" \
        -DCMAKE_INSTALL_PREFIX=${PREFIX}

        #-DLINALG=OpenBLAS \
        #-DOPENBLASROOT=$PREFIX \
        # globalarrays not yet on conda-forge!
        #    -DGA=ON \

    #  FC=mpif90 CC=mpicc CXX=mpicxx cmake    
    # cpp executable name harcoded in CMakeLists.txt
    ln -s $CPP ${PREFIX}/bin/cpp

fi


make

# Full test suite is taking too long
pymolcas verify .basic

make install
