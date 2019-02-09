#!/bin/bash

set -x
echo $PREFIX
export CXXFLAGS="${CXXFLAGS} -O2 -pipe -march=x86-64 -std=c++11 -fPIC -fopenmp"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

./configure --prefix=${PREFIX} --enable-shared

make -j4
make -j4 check
make -j4 install
