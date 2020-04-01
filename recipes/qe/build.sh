#!/bin/bash
./configure ARCH="x86_64"LIBDIRS="${PREFIX}/lib" CC="${CC}" CPP="${CPP}" LD="mpif90 -fopenmpi" CFLAGS="${CFLAGS}" FFLAGS="${FFLAGS}" CPPFLAGS="${CPPFLAGS}" 
make all
