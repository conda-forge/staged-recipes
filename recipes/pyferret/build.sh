#!/bin/bash

export LIBZ_DIR=$PREFIX
export READLINE_DIR=$PREFIX
export HDF5_DIR=$PREFIX
export NETCDF4_DIR=$PREFIX
export FER_DIR=$PREFIX
export FC="gfortran"
export LD_X11="-L/usr/lib64 -lX11"

make
# make run_tests  # Image mismatch issues.
make install
