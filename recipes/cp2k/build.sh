#!/bin/bash
cp /home/conda/conda-recipes/cp2k/Linux-x86-64-conda.sopt Linux-x86-64-conda.sopt
make -j${CPU_COUNT} ARCH=Linux-x86-64-conda VERSION=sopt
cp ./exe/cp2k ${PREFIX}/bin
