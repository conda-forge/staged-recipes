#!/bin/bash

./configure --prefix="$PREFIX" \
    --disable-manpages \
    --with-libgcrypt-prefix="$PREFIX"

# Requires python-dbus and some other stuff
make check

make install
