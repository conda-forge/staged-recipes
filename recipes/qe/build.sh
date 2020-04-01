#!/bin/bash
./configure ARCH="x86_64" LIBDIRS="${PREFIX}/lib" CC="${CC}" CPP="${CPP}" LD="${LD}" CFLAGS="${CFLAGS}" FFLAGS="${FFLAGS}" CPPFLAGS="${CPPFLAGS}"
# LDFLAGS="${LDFLAGS} -fopenmpi" 
# --disable-parallel 
# CFLAGS="${CFLAGS}" FFLAGS="${FORTRANFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS} -fopenmpi"
# CC="${CC}" CPP="${CPP}" MPIF90=mpif90 
make all
