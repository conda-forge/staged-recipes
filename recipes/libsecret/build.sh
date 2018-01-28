#!/bin/bash

# Nasty hack for $PREFIX/bin/intltool-*
ln -s "$PREFIX/bin/perl" "$PREFIX/bin/perl -w"

./configure --prefix="$PREFIX" \
    --disable-manpages \
    --with-libgcrypt-prefix="$PREFIX"

# Requires python-dbus and some other stuff
# make check

make install

unlink "$PREFIX/bin/perl -w"
