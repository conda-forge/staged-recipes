#!/bin/bash
./configure ARCH="x86_64"
# --disable-parallel 
# LIBDIRS="${PREFIX}/lib" LD="${LD}" CFLAGS="${CFLAGS}" FFLAGS="${FORTRANFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS} -fopenmpi"
# CC="${CC}" CPP="${CPP}" MPIF90=mpif90 
make all
