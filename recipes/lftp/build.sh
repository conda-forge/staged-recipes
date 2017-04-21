#!/bin/bash

IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

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

# On Windows we need to regenerate the configure scripts.
if [ -n "$VS_MAJOR" ] ; then
    am_version=1.15 # keep sync'ed with meta.yaml
    export ACLOCAL=aclocal-$am_version
    export AUTOMAKE=automake-$am_version
    autoreconf_args=(
        --force
        --install
        -I "$mprefix/share/aclocal"
        -I "$mprefix/mingw-w64/share/aclocal" # note: this is correct for win32 also!
    )
    # autopoint assumes that gettext/archive.dir.tar.xz can be found in
    # $prefix/share/, with prefix = /mingw32 using the m2* packages
    # in our depends. That file isn't found by `xz` though, so we override
    # the path via environment variable `gettext_datadir`:
    export gettext_datadir=$mprefix/mingw-w64/share/gettext
    autoreconf "${autoreconf_args[@]}"
fi

export PKG_CONFIG_LIBDIR=$uprefix/lib/pkgconfig:$uprefix/share/pkgconfig
export LDFLAGS="$LDFLAGS -Wl,-rpath -Wl,$PREFIX/lib -L$PREFIX/lib"
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -O2 -g"
configure_args=(
    --prefix=$PREFIX
    --with-sysroot=$PREFIX
    --disable-dependency-tracking
    --disable-silent-rules
    --without-gnutls
    --with-openssl
    --with-readline=$PREFIX
    --without-libresolv
    --without-libidn
)

./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install
make check

# Remove documentation
rm -rf $uprefix/share/man $uprefix/share/doc

# Non-Windows: prefer dynamic libraries to static, and dump libtool helper files
if [ -z "$VS_MAJOR" ] ; then
    for lib_ident in Xp; do
        rm -f $uprefix/lib/lib${lib_ident}.la $uprefix/lib/lib${lib_ident}.a
    done
fi
