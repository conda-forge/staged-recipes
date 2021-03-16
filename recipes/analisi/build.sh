#!/bin/bash

ARGS="-DSYSTEM_FFTW3=ON -DSYSTEM_EIGEN3=ON -DSYSTEM_BOOST=ON -DSYSTEM_XDRFILE=ON"

mkdir build_serial
cd build_serial
cmake ../ -DPYTHON_EXECUTABLE="$PYTHON" $ARGS
make
make test
cp -v analisi "$PREFIX/bin/analisi_serial"
cp -v pyanalisi*.so "$SP_DIR/pyanalisi.so"

cd ../
mkdir build_mpi
cd build_mpi
cmake ../ -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_C_COMPILER=mpicc -DUSE_MPI=ON -DPYTHON_EXECUTABLE="$PYTHON" $ARGS
make
make test
cp -v analisi "$PREFIX/bin/analisi"
