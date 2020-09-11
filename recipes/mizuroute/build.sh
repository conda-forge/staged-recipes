#!/bin/bash

export F_MASTER="../"
export FC_EXE=${FC}
export EXE="route_runoff.exe"
export MODE="fast"
export NCDF_PATH=${PREFIX}
export EXE_PATH="${PREFIX}/bin"
export FLAGS="-p -g -Wall -ffree-line-length-none -fmax-errors=0 -fbacktrace -fcheck=bounds"

patch route/build/Makefile ${RECIPE_DIR}/make.patch

cd $(pwd)/route/build
make -f Makefile
mv $F_MASTER/bin/route_runoff.exe $PREFIX/bin/route_runoff.exe
