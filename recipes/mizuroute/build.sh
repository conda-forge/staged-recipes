#!/bin/bash

export F_MASTER="../"
export FC="gnu"
export FC_EXE=${FC}
export EXE="route_runoff.exe"
export MODE="fast"
export NCDF_PATH=${PREFIX}
export EXE_PATH="${PREFIX}/bin"

echo '------------------------------'
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo ${RECIPE_DIR}
echo `ls ${RECIPE_DIR}`
echo `ls ..`
echo '------------------------------'

patch route/build/Makefile ${RECIPE_DIR}/make.patch


cd $(pwd)/route/build
make -f Makefile
mv $F_MASTER/bin/route_runoff.exe $PREFIX/bin/route_runoff.exe
