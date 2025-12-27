#!/bin/sh
set -e

./configure \
	--prefix=$PREFIX \
	--with-blas \
	--with-bzlib \
	--with-lapack \
	--with-nls \
	--with-openmp \
	--with-pdal \
	--with-postgres \
	--with-pthread \
	--with-readline \
	--with-wxwidgets

# ignore system built-in libiconv and use conda libiconv
sed -Ei 's/^(ICONVLIB.*= *$)/\1-liconv/' include/Make/Platform.make

make -j$CPU_COUNT
make install
