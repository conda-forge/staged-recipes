#!/bin/bash
set -ex

mkdir build
cd build

cmake .. 

cmake --build build --target install


#configopts = ' --with-mpi --enable-i8'
#configopts += ' --with-blas8="-L$MLROOT/lib/intel64 -lmkl_sequential -lmkl_intel_ilp64"'
#configopts += ' --with-scalapack8="L$MKLROOT/lib/intel64 -lmkl_scalapack_ilp64 -lmkl_intel_ilp64 '
#configopts += '-lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_ilp64 -lpthread -lm -ldl"'

# select armci network as (Comex) MPI-1 two-sided
#configopts += ' --with-mpi-ts'
