#!/bin/bash
./configure --disable-parallel LIBDIRS="${PREFIX}/lib" ARCH="x86_64" LD="${LD}" CFLAGS="${CFLAGS}" FFLAGS="${FORTRANFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS} -fopenmpi"
# CC="${CC}" CPP="${CPP}" MPIF90=mpif90 
make all
