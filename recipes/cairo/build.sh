#!/bin/bash

export CFLAGS="-I$PREFIX/include -L$PREFIX/lib"

# As of Mac OS 10.8, X11 is no longer included by default
# (See https://support.apple.com/en-us/HT201341 for the details).
# Due to this change, we disable building X11 support for cairo on Mac by
# default.
export XWIN_ARGS=""
if [ `uname` == Darwin ]; then
   export XWIN_ARGS="--disable-xlib -disable-xcb --disable-glitz"
fi

./configure                                  \
    --prefix="${PREFIX}"                     \
    --disable-gobject                        \
    --enable-warnings                        \
    --enable-ft                              \
    --enable-ps                              \
    --enable-pdf                             \
    --enable-svg                             \
    --disable-gtk-doc                        \
    $XWIN_ARGS

make
make install

rm -rf $PREFIX/share
