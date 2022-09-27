#!/bin/sh

export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

perl Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1 libs="-L$PREFIX/lib -lz"
make libs="-L$PREFIX/lib -lz"
make test libs="-L$PREFIX/lib -lz"
make install VERBINST=1 libs="-L$PREFIX/lib -lz"
