#!/bin/bash

# Nasty hack for $PREFIX/bin/intltool-*
ln -s "$BUILD_PREFIX/bin/perl" "$BUILD_PREFIX/bin/perl -w"

./configure --prefix="$PREFIX" \
    --disable-manpages \
    --with-libgcrypt-prefix="$PREFIX"

# Requires python-dbus and some other stuff
make check

make install

unlink "$BUILD_PREFIX/bin/perl -w"
