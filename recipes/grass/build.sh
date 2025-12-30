#!/bin/sh
set -e

case "$target_platform" in
osx-*)
	with_others="
		--with-opengl=osx
		--with-x=no
	"
	sed_i_ext="''"
	;;
esac

./configure \
	--prefix=$PREFIX \
	--with-blas \
	--with-bzlib \
	--with-lapack \
	--with-nls \
	--with-openmp \
	--with-postgres \
	--with-pthread \
	--with-readline \
	$with_others

# ignore system built-in libiconv and use conda libiconv
sed -E -i $sed_i_ext 's/^(ICONVLIB.*= *$)/\1-liconv/' include/Make/Platform.make

make -j$CPU_COUNT
make install
