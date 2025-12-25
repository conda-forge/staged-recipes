#!/bin/sh
set -e

./configure \
	--prefix=$PREFIX \
	--with-nls \
	--with-readline \
	--with-wxwidgets \
	--with-bzlib \
	--with-postgres \
	--with-pthread \
	--with-openmp \
	--with-blas \
	--with-lapack \
	--with-pdal

# ignore system built-in libiconv and use conda libiconv
sed -Ei 's/^(ICONVLIB.*= *$)/\1-liconv/' include/Make/Platform.make

make -j$CPU_COUNT
make install
