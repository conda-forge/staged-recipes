#!/bin/bash
./configure ARCH="x86_64" MPIF90="mpif90 -fopenmpi" LIBDIRS="${PREFIX}/lib" CC="${CC}" CPP="${CPP}" LD="${LD}" CFLAGS="${CFLAGS}" FFLAGS="${FFLAGS}" CPPFLAGS="${CPPFLAGS}"
# LDFLAGS="${LDFLAGS} -fopenmpi" 
make all
