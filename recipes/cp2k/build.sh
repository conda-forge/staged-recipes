#!/bin/bash
cp /home/conda/conda-recipes/cp2k/Linux-x86-64-conda.sopt arch/Linux-x86-64-conda.sopt
cd makefiles
make -j${CPU_COUNT} ARCH=Linux-x86-64-conda VERSION=sopt
make -j${CPU_COUNT} ARCH=Linux-x86-64-conda VERSION=sopt test
cd ${SRC_DIR}
mkdir ${PREFIX}/bin
cp exe/Linux-x86-64-conda/cp2k.sopt ${PREFIX}/bin/cp2k.sopt
cp exe/Linux-x86-64-conda/cp2k_shell.sopt ${PREFIX}/bin/cp2k_shell.sopt
