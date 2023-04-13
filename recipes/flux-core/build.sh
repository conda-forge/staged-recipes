#!/bin/bash
export CPPFLAGS="-D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include"
./configure --prefix=${PREFIX}
make
export FLUX_TEST_MPI=t
make check 
make install
