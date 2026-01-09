#!/bin/sh
set -e

case "$target_platform" in
osx-*)
	with_others="
		--with-opengl=osx
		--with-x=no
	"
	;;
esac

CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY" \
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
	$with_others ||
	(echo "===== config.log =====" && cat config.log && exit 1)

sed -Ei 's/^(ICONVLIB *= *$)/\1-liconv/' include/Make/Platform.make

make -j$CPU_COUNT
make install
