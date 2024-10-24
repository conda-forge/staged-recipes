#!/bin/bash

set -x

autoreconf -vfi

export CC=mpicc
export FC=mpifort

if [[ "${mpi}" == "openmpi" ]]; then
  export MPI_LAUNCH="${PREFIX}/bin/mpirun --oversubscribe"
  export OMPI_MCA_plm_rsh_agent=""
else
  export MPI_LAUNCH="${PREFIX}/bin/mpirun"
fi

./configure --prefix=${PREFIX} \
            --with-mpi-root=${PREFIX} \
            --with-pic

make -j ${CPU_COUNT} all
make install
