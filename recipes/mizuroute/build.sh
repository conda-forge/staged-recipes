#!/bin/bash

export F_MASTER="../"
sed -e "s/FC  =/FC = gnu/g"  \
    -e "s/FC_EXE =/FC_EXE = gfortran/g" \
    -e "s/^EXE =/EXE = route_runoff.exe/g" \
    -e "s/MODE = debug/MODE = fast/g" \
    -e "s|F_MASTER =|F_MASTER = $F_MASTER|g" \
    -e "s|NCDF_PATH =|NCDF_PATH=${PREFIX}|g" \
    route/build/Makefile > route/build/myMakefile

export EXE_PATH="$PREFIX/bin"
cd $(pwd)/route/build
make -f myMakefile
mv $F_MASTER/bin/route_runoff.exe $PREFIX/bin/route_runoff.exe
