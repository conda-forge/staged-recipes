#!/bin/bash

CPPFLAGS="-I${PREFIX}/include" \
CXXFLAGS="${CXXFLAGS} -O3" \
CFLAGS="${CFLAGS} -std=c99" \
LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}" \
./configure \
--prefix="${PREFIX}" \
--disable-mpi \
--disable-fortran \
--with-cfitsio="${PREFIX}"

make
make install
rm -f "${PREFIX}/lib/*.la"

