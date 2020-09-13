#!/bin/bash

export F_MASTER="../"
export FC_EXE=${FC}
export EXE="route_runoff.exe"
export MODE="fast"
export NCDF_PATH=${PREFIX}
export EXE_PATH="${PREFIX}/bin"
export FLAGS="-O3 -fmax-errors=0 -ffree-line-length-none"
export LIBNETCDF="-Wl,-rpath,$(NCDF_PATH)/lib -L$(NCDF_PATH)/lib -lnetcdff -lnetcdf"
export INCNETCDF="-I$(NCDF_PATH)/include"

cd $(pwd)/route/build
make -f Makefile
mv $F_MASTER/bin/route_runoff.exe $PREFIX/bin/route_runoff.exe
