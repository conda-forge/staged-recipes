#!/bin/bash
set -ex

ls "${PREFIX}/include/libxml2"
ls "${PREFIX}/include/libxml2/libxml"

export FC=mpif90 
export CC="mpicc"
export CFLAGS="${CFLAGS} -I${PREFIX}/include/libxml2"
./configure.sh AUTO

cd build; make; cd -

mkdir -p ${PREFIX}/bin
cp build/fleur_MPI ${PREFIX}/bin
cp build/inpgen ${PREFIX}/bin
