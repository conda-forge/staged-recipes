#!/usr/bin/env bash

set -euxo pipefail

cp config/make.inc.gfort make.inc

# Conda-build provides a prefixed Fortran compiler (for example
# x86_64-conda-linux-gnu-gfortran), while upstream defaults to plain
# "gfortran". Bind Wannier90's F90 setting to conda's FC to avoid relying on
# a non-prefixed compiler binary.
sed -i "s|^F90 = .*|F90 = ${FC}|" make.inc

# Upstream assumes BLAS/LAPACK are available in system linker paths. In
# conda-build, they are provided in ${PREFIX}/lib, so add an explicit -L path.
sed -i "s|^LIBS = .*|LIBS = -L${PREFIX}/lib -llapack -lblas|" make.inc

make install PREFIX="${PREFIX}"
