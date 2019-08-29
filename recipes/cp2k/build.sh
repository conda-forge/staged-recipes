#!/bin/bash
cp /home/conda/conda-recipes/cp2k/Linux-x86-64-conda.sopt arch/Linux-x86-64-conda.sopt
cd cmakefiles
make -j${CPU_COUNT} ARCH=Linux-x86-64-conda VERSION=sopt
cd ..
cp ./exe/cp2k ${PREFIX}/bin
