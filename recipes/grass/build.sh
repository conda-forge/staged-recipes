#!/bin/sh
set -e

./configure \
	--prefix=$PREFIX \
	--with-blas \
	--with-bzlib \
	--with-lapack \
	--with-nls \
	--with-openmp \
	--with-postgres \
	--with-pthread \
	--with-readline

# ignore system built-in libiconv and use conda libiconv
sed -Ei 's/^(ICONVLIB.*= *$)/\1-liconv/' include/Make/Platform.make

make -j$CPU_COUNT
make install
