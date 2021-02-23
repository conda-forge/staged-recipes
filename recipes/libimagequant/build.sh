#!/bin/bash

./configure --prefix=$PREFIX --with-openmp
make -j$CPU_COUNT shared imagequant.pc
make install
