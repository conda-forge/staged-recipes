#!/bin/bash

./configure --prefix=$PREFIX --with-openmp --with-libimagequant=${PREIFIX}/lib
make -j$CPU_COUNT
make test
make install

