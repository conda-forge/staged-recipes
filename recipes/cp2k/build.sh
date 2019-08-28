#!/bin/bash
make -j${CPU_COUNT} ARCH=Linux-x86-64-gfortran VERSION=sopt
cp ./exe/cp2k ${PREFIX}/bin
