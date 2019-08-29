#!/bin/bash
cp /home/conda/conda-recipes/cp2k/Linux-x86-64-conda.sopt arch/Linux-x86-64-gfortran.sopt
cd tools/toolchain
./install_cp2k_toolchain.sh  \
    --mpi-mode=no                \
    --with-gcc=system            \
    --with-cmake=system          \
    --with-fftw=system           \
    --with-openblas=system       \
    --with-reflapack=system      \
    --with-gsl=system            \
    --with-libxc=system          \
    --with-libxsmm=system        \
cd ../..
make -j${CPU_COUNT} ARCH=Linux-x86-64-gfortran VERSION=sopt
cp ./exe/cp2k ${PREFIX}/bin
