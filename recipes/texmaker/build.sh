#!/bin/bash

ln -s $CC ${PREFIX}/bin/gcc
ln -s $CXX ${PREFIX}/bin/g++

qmake -set prefix $PREFIX
qmake PREFIX=$PREFIX texmaker.pro
make -j$CPU_COUNT
make install PREFIX=$PREFIX
