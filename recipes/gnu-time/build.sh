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
else
    mprefix="$PREFIX"
    uprefix="$PREFIX"
fi

./configure \
    --prefix=$mprefix \
    --disable-dependency-tracking \
    --mandir=$mprefix/share/man \
    --infodir=$mprefix/share/info \
    --program-prefix=g \
    || (cat config.log; false)


make -j$CPU_COUNT
make check -j$CPU_COUNT
make install
