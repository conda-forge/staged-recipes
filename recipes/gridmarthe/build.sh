#!/bin/bash

cd $SRC_DIR/src/gridmarthe/lecsem
gfortran --version || { echo "gfortran not available"; exit 1; }
CC=gcc FC=gfortran FFLAGS='-fdefault-real-8' $PYTHON -m numpy.f2py -c lecsem.f90 edsemigl.f90 scan_grid.f90 -m lecsem --backend=meson --lower

echo "\n\n\n COMPILATION DONE \n\n\n"
cd $SRC_DIR
# no-deps : already installed with conda, do not try hell...
$PYTHON -m pip install -v . 
# --no-deps -v


