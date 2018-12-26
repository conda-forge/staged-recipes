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

# Fix undefined symbol error _lame_init_old
# https://sourceforge.net/p/lame/mailman/message/36081038/
# original patch from the homebrew recipe:
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/lame.rb
# inreplace "include/libmp3lame.sym", "lame_init_old\n", ""

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
