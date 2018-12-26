#!/bin/bash

export CFLAGS="-I$PREFIX/include $CFLAGS"

if [[ $(uname) == Darwin ]]; then
    export CC=clang
    export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -headerpad_max_install_names $LDFLAGS"
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    export MACOSX_DEPLOYMENT_TARGET="10.9"
elif [ $(uname) == Linux ] ; then
    export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
fi

# remove libtool files
find $PREFIX -name '*.la' -delete

./configure --prefix=$PREFIX \
	    --disable-dependency-tracking \
	    --disable-debug \
	    --enable-nasm

make -j$CPU_COUNT
make install -j$CPU_COUNT

# test
$PREFIX/bin/lame --genre-list testcase.mp3

# remove libtool files
find $PREFIX -name '*.la' -delete
