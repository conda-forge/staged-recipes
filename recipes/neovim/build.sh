#!/bin/sh
set -x -e

#export CC=${PREFIX}/bin/gcc
#export CXX=${PREFIX}/bin/g++

export PATH=${PREFIX}/bin:$PATH
export INCLUDE_PATH="${PREFIX}/include"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CPATH="${PREFIX}/include"

export LIBDIR="${PREFIX}/lib"

sed -i "43 a CMAKE_EXTRA_FLAGS := -DCMAKE_INSTALL_PREFIX=$PREFIX" Makefile

make
make install
