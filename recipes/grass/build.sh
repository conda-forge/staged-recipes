#!/bin/sh
set -e

case "$target_platform" in
osx-*)
	# pdal requires this define
	# $PREFIX/include/pdal/FileSpec.hpp:60:22: error: 'path' is
	# unavailable: introduced in macOS 10.15 unknown - see
	# https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
	[ "$target_platform" = "osx-64" ] &&
		CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
	with_others="
		--with-opengl=osx
		--with-x=no
	"
	;;
esac

CXXFLAGS="$CXXFLAGS" \
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

# ignore system built-in libiconv and use conda libiconv; avoid using
# non-portable sed -i
platform_make=include/Make/Platform.make
sed -E 's/^(ICONVLIB *= *$)/\1-liconv/' $platform_make > $platform_make.tmp
mv $platform_make.tmp $platform_make

make -j$CPU_COUNT
make install
