#!/bin/bash
mkdir m4

# Patch the configure.ac as per https://lists.ubuntu.com/archives/fwts-devel/2013-June/003391.html
sed -i".ac" -e 's/AM_PROG_AR/m4_ifdef([AM_PROG_AR], [AM_PROG_AR])/g' configure.ac
autoreconf --install

CFLAGS="-O3 -mfpmath=sse -msse"

if [[ $(uname) == Darwin ]]
then
    CFLAGS="$CFLAGS -D_DARWIN_SOURCE"
fi
./configure --prefix=$PREFIX CFLAGS="$CFLAGS"

make
make check
make install
