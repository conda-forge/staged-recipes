#!/bin/bash

#export FFLAGS="$FFLAGS -fdefault-real-8"
cd $SRC_DIR/src/gridmarthe/lecsem
$PYTHON -m numpy.f2py -c lecsem.f90 edsemigl.f90 scan_grid.f90 -m lecsem --backend=meson --lower
echo "\n\n\n COMPILATION DONE \n\n\n"
cd $SRC_DIR
# no-deps : already installed with conda, do not try hell...
$PYTHON -m pip install -v . 
# --no-deps -v


