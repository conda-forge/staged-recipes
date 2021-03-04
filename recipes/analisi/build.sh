#!/bin/bash

mkdir build_serial
cd build_serial
cmake ../
make
cp analisi "$PREFIX/bin/analisi_serial"
cp pyanalisi*.so "`python -c 'import sys;print(sys.path[-1],end="")'`"

cd ../
mkdir build_mpi
cd build_mpi
cmake ../ -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_C_COMPILER=mpicc -DUSE_MPI=ON
make
cp analisi "$PREFIX/bin/analisi"
