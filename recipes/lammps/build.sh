#!/bin/bash

cd src
make yes-standard no-kim no-gpu no-kokkos no-mpiio no-mscg no-voronoi no-latte yes-user-meamc yes-user-phonon
cd ../lib/meam/
make -f Makefile.gfortran
cd ../poems
make -f Makefile.g++
cd ../reax/
make -f Makefile.gfortran
cd ../../src
make serial LMP_INC="-DLAMMPS_EXCEPTIONS"
cp lmp_serial $PREFIX/bin/lmp_serial
# MPI version are only compiled for Linux 
if [ $OSX_ARCH != "i386" ] && [ $OSX_ARCH != "x86_64" ]
then
    make mpi LMP_INC="-DLAMMPS_EXCEPTIONS"
    cp lmp_mpi $PREFIX/bin/lmp_mpi
fi
make serial mode=shlib LMP_INC="-DLAMMPS_EXCEPTIONS"
cd ../python
python install.py
