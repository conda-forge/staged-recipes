#!/usr/bin/env bash
set -eux

# TODO: probably want pcre, but keep segfaulting with 8.44
./configure \
    --prefix=$PREFIX \
    --disable-pcre

make chktex

make install

if [ `uname` == Darwin ]; then
    install_name_tool -change /usr/lib/libncurses.5.4.dylib "$PREFIX"/sysroot/usr/lib/libncurses.5.4.dylib "$PREFIX"/bin/chktex || true
fi

make test
