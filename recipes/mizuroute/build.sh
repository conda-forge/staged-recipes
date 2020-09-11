#!/bin/bash

export F_MASTER="../"
export FC="gnu"
export FC_EXE=${FC}
export EXE="route_runoff.exe"
export MODE="fast"
export NCDF_PATH=${PREFIX}
export EXE_PATH="${PREFIX}/bin"
patch route/build/Makefile $(pwd)/make.patch

cd $(pwd)/route/build
make -f Makefile
mv $F_MASTER/bin/route_runoff.exe $PREFIX/bin/route_runoff.exe
