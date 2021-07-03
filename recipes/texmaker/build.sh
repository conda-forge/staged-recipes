#!/bin/bash

mkdir build
cd build

qmake \
    PREFIX=$PREFIX \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    ../texmaker.pro

make -j$CPU_COUNT
make check
sed -i 's:(INSTALL_ROOT)/usr:(INSTALL_ROOT):g' Makefile
make install
