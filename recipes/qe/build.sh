#!/bin/bash
./configure --disable-parallel LIBDIRS="${PREFIX}/lib" ARCH="x86_64" CC="${CC}" CPP="${CPP}" LD="${LD}" CFLAGS="${CFLAGS}" FFLAGS="${FORTRANFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS} -fopenmpi" MPIF90=mpif90 
make all
