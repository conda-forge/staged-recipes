#!/bin/bash

export CXXFLAGS="$CXXFLAGS -std=c++14"

mkdir build
autoconf
cd build
../configure PYTHON=`which python` --prefix=$PREFIX
make -j$CPU_COUNT
make install
