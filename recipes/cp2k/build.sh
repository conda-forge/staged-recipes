#!/bin/bash
cp Linux-x86-64-conda.sopt arch/Linux-x86-64-conda.sopt
make -j${CPU_COUNT} ARCH=Linux-x86-64-conda VERSION=sopt
cp ./exe/cp2k ${PREFIX}/bin
