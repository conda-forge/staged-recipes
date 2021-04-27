#!/bin/bash
set -ex

ls "${PREFIX}/include/libxml2"
#ls "${PREFIX}/include/libxml2/libxml"

export FC=mpif90 
export FLEUR_INCLUDEDIR="${PREFIX}/include;${PREFIX}/include/libxml2"
export FLEUR_LIBRARIES="-L${PREFIX}/lib;-lfftw3;-lxml2;-lblas;-llapack;-lscalapack"

export CC="mpicc"
#export LIBXML2_INCLUDE_DIR=${PREFIX}/include/libxml2
#export CFLAGS="${CFLAGS} -I$"
./configure.sh

cd build; make; cd -

mkdir -p ${PREFIX}/bin
cp build/fleur_MPI ${PREFIX}/bin
cp build/inpgen ${PREFIX}/bin
