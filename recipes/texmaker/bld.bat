#!/bin/bash

qmake -set prefix $PREFIX
qmake PREFIX=$PREFIX texmaker.pro
make -j$CPU_COUNT
make install PREFIX=$PREFIX
