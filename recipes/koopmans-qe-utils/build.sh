#!/bin/bash
set -ex

mkdir build
cd build

ls $PREFIX/lib

cmake .. \
    -DQE_ENABLE_MPI=ON \
    -DQE_ENABLE_OPENMP=ON \
    -DQE_ENABLE_SCALAPACK=ON \
    -DQE_ROOT=${PREFIX} \
    -DQE_ENABLE_HDF5=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}
 
make

#if [[ "$mpi" == "openmpi" ]]; then
export OMPI_MCA_plm_rsh_agent=sh
#fi

make install
