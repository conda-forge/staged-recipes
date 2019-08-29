#!/bin/bash
cp /home/conda/conda-recipes/cp2k/Linux-x86-64-conda.sopt arch/Linux-x86-64-gfortran.sopt
make -j${CPU_COUNT} ARCH=Linux-x86-64-gfortran VERSION=sopt install
cp ./exe/cp2k ${PREFIX}/bin
