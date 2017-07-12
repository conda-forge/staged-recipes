#!/bin/bash

# Adopt a Unix-friendly path if we're on Windows (see bld.bat).
[ -n "$PATH_OVERRIDE" ] && export PATH="$PATH_OVERRIDE"

LDFLAGS="$LDFLAGS -L$PREFIX/lib"
CFLAGS="$CFLAGS -O3 -I$PREFIX/include"

# The AppVeyor build sets "TARGET_ARCH" to x86 or x64. We need to unset
# this, as TARGET_ARCH is put on the command line by Make via
# its default rules for compiling C files.
export TARGET_ARCH=

make -j$CPU_COUNT LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
make test

# Use different variable to get "binprefix" on win:
if [ -n "$LIBRARY_BIN" ]; then
    cp pigz unpigz $LIBRARY_BIN
else
    cp pigz unpigz $PREFIX/bin
fi
