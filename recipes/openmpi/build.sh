#!/bin/bash

OPTS=""

if [ "$(uname)" == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
    export CC=clang
    export CXX=clang++
    export MACOSX_DEPLOYMENT_TARGET="10.9"
    export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    OPTS="--disable-mpi-fortran"
fi


./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            $OPTS


make -j $CPU_COUNT
make check
make install
