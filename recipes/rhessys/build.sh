#!/bin/bash

if [[ $(uname) == Linux ]]; then
  ln -s "${CC}" "${BUILD_PREFIX}/bin/gcc"
fi

export F_MASTER=$(pwd)
export FC_ENV=$(uname)

export INCLUDES='-I${PREFIX}/include -I/usr/include'
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"
export FLAGS_COMM="-fPIC -p -g -Wall -ffree-line-length-none -fmax-errors=0 -fbacktrace -fcheck=bounds"
export FLAGS_RHESSYS=${FLAGS_COMM}

export EXE_PATH="$PREFIX"
make -C ${F_MASTER} -f makefile
mv $F_MASTER/rhessysecv.7.2.0 $PREFIX/rhessysecv.7.2.0