#!/bin/sh
set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++


export PATH=${PREFIX}/bin:$PATH
export INCLUDE_PATH="${PREFIX}/include"
#export LIBRARY_PATH="${PREFIX}/lib"
#export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CPATH="${PREFIX}/include"

export LIBDIR="${PREFIX}/lib"

yum install -y unzip

sed -i "43 a CMAKE_EXTRA_FLAGS := -DCMAKE_INSTALL_PREFIX=$PREFIX" Makefile
#echo "CMAKE_EXTRA_FLAGS := -DCMAKE_INSTALL_PREFIX=$PREFIX" > local.mk

#make clean
#make distclean
make
make install
