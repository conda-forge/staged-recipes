#!/bin/bash
cp /home/conda/conda-recipes/cp2k/Linux-x86-64-conda.sopt arch/Linux-x86-64-conda.sopt
cd makefiles
make -j${CPU_COUNT} ARCH=Linux-x86-64-conda VERSION=sopt
ls -al ../exe/Linux-x86-64-conda
cp ../exe/Linux-x86-64-conda ${PREFIX}/bin/cp2k
