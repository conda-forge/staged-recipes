#!/bin/sh
set -x -e

export PATH=${PREFIX}/bin:$PATH
export INCLUDE_PATH="${PREFIX}/include"

export LDFLAGS="-L${PREFIX}/lib -liconv"

export CPPFLAGS="-I${PREFIX}/include"

export CPATH="${PREFIX}/include"
export LIBDIR="${PREFIX}/lib"

export CFLAGS="-I${PREFIX}/include"
export CFLAGS="-fPIC $CFLAGS"

if [ `uname -m` == Darwin ]; then
	
	brew remove pkg-config
	brew remove libiconv
	
	export LIBTOOLIZE="${PREFIX}/bin/libtoolize"
	export LD_LIBRARY_PATH="${PREFIX}/lib"
	#export DYLD_LIBRARY_PATH="${PREFIX}/lib"
	unset DYLD_LIBRARY_PATH
	export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

ln -s ${PREFIX}/bin/libtoolize ${PREFIX}/bin/glibtoolize
ln -s ${PREFIX}/bin/libtool ${PREFIX}/bin/glibtool

make
make install
