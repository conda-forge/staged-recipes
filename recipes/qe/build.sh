#!/bin/bash
./configure --disable-parallel LIBDIRS="${PREFIX}/lib" ARCH="x86_64" F90="${F90}" F77="${F77}" CC="${CC}" CPP="${CPP}" LD="${LD}" CFLAGS="${CFLAGS}" FFLAGS="${FFLAGS}" CPPFLAGS="${CPPFLAGS} LDFLAGS="${LDFLAGS} -fopenmpi" MPIF90=mpif90 
make all
