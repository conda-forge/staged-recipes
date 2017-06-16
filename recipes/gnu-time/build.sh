#!/bin/bash
set -x
set -e

# Adopt a Unix-friendly path if we're on Windows (see bld.bat).
[ -n "$PATH_OVERRIDE" ] && export PATH="$PATH_OVERRIDE"

# On Windows we want $LIBRARY_PREFIX in both "mixed" (C:/Conda/...) and Unix
# (/c/Conda) forms, but Unix form is often "/" which can cause problems.
if [ -n "$LIBRARY_PREFIX_M" ] ; then
    mprefix="$LIBRARY_PREFIX_M"
    if [ "$LIBRARY_PREFIX_U" = / ] ; then
        uprefix=""
    else
        uprefix="$LIBRARY_PREFIX_U"
    fi
    # And we need to add the search path that lets libtool find the
    # msys2 stub libraries for ws2_32.
    platlibs=$(cd $(dirname $(gcc --print-prog-name=ld))/../lib && pwd -W)
    export LDFLAGS="$LDFLAGS -L$platlibs"
else
    mprefix="$PREFIX"
    uprefix="$PREFIX"
fi

./configure \
    --prefix=$mprefix \
    --disable-dependency-tracking \
    --mandir=$mprefix/share/man \
    --infodir=$mprefix/share/info \
    || (cat config.log; false)


make -j$CPU_COUNT
make check -j$CPU_COUNT
make install
