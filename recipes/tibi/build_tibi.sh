#!/usr/bin/env bash

set -ex

CPPFLAGS="${CPPFLAGS} -D_NODEBUG -D_OMP -D_ELPA"
FFLAGS="${FFLAGS} -I${PREFIX}/include -I${PREFIX}/include/elpa_onenode_openmp/modules -fopenmp -funroll-loops"
LDFLAGS="${LDFLAGS} -lgomp -lxsmmf -lxsmm -lxsmmext -lelpa_onenode_openmp -lblas -llapack"
make clean
make -j${CPU_COUNT}
cp build/bin/* ${PREFIX}/bin/
