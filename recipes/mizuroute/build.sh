#!/bin/bash

if [[ $(uname) == Linux ]]; then
  ln -s "${CC}" "${BUILD_PREFIX}/bin/gcc"
  ln -s "${FC}" "${BUILD_PREFIX}/bin/gfortran"
fi

export F_MASTER=$(pwd)
# export FC=gfortran
export FC_EXE=${FC}
export FC_ENV=$(uname)
export NCDF_PATH=${PREFIX}
export INCLUDES='-I${PREFIX}/include -I/usr/include'
export LIBRARIES='-L${PREFIX}/lib -lnetcdff'

export EXE_PATH="$PREFIX/bin"
make -C ${F_MASTER}/route/build/ -f Makefile
mv $F_MASTER/bin/route_runoff.exe $PREFIX/bin/route_runoff.exe
