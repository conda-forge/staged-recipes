#!/usr/bin/env bash

set -xe

F90_OPTS="-O3 -ffast-math -funroll-loops -fopenmp -fallow-argument-mismatch"
F77_OPTS=$F90_OPTS
LIB_LPK="-L${PREFIX}/lib -llapack -lopenblas -lgfortran"
LIB_FFT="fftlib.a"

echo > make.inc
echo "MAKE = make" >> make.inc
echo "F90 = $F90" >> make.inc
echo "F90_OPTS = $F90_OPTS" >> make.inc
echo "F77 = $F77" >> make.inc
echo "F77_OPTS = $F77_OPTS" >> make.inc
echo "AR = $AR" >> make.inc
echo "LIB_SYS = " >> make.inc
echo "# LAPACK and BLAS libraries" >> make.inc
echo "LIB_LPK = $LIB_LPK" >> make.inc
echo "LIB_FFT = $LIB_FFT" >> make.inc
echo "SRC_OMP = " >> make.inc
cat make.def >> make.inc

make all

install -m 0755 src/elk ${PREFIX}/bin/
install -m 0755 src/eos/eos ${PREFIX}/bin/
install -m 0755 src/spacegroup/spacegroup ${PREFIX}/bin/
