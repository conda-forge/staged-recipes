#!/bin/bash

mkdir build_serial
cd build_serial
cmake ../ -DBUILD_TESTS=OFF
make
cp -v analisi "$PREFIX/bin/analisi_serial"
cp -v pyanalisi*.so "$SP_DIR/pyanalisi.so"

cd ../
mkdir build_mpi
cd build_mpi
cmake ../ -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_C_COMPILER=mpicc -DUSE_MPI=ON -DBUILD_TESTS=OFF
make
cp -v analisi "$PREFIX/bin/analisi"
