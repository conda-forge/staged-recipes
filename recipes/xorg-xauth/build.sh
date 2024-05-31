#!/bin/bash
set -ex

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

# Cf. https://github.com/conda-forge/staged-recipes/issues/673, we're in the
# process of excising Libtool files from our packages. Existing ones can break
# the build while this happens. We have "/." at the end of $uprefix to be safe
# in case the variable is empty.
find $uprefix/. -name '*.la' -delete

# On Windows we need to regenerate the configure scripts.
if [ -n "$CYGWIN_PREFIX" ] ; then
    am_version=1.15 # keep sync'ed with meta.yaml
    export ACLOCAL=aclocal-$am_version
    export AUTOMAKE=automake-$am_version
    autoreconf_args=(
        --force
        --install
        -I "$mprefix/share/aclocal"
        -I "$BUILD_PREFIX_M/Library/mingw-w64/share/aclocal"
    )
    autoreconf "${autoreconf_args[@]}"

    # And we need to add the search path that lets libtool find the
    # msys2 stub libraries for ws2_32.
    platlibs=$(cd $(dirname $(gcc --print-prog-name=ld))/../lib && pwd -W)
    export LDFLAGS="$LDFLAGS -L$platlibs"

    export PKG_CONFIG_LIBDIR=$uprefix/lib/pkgconfig:$uprefix/share/pkgconfig
    configure_args=(
        $CONFIG_FLAGS
        --disable-dependency-tracking
        --disable-selective-werror
        --disable-silent-rules
        --disable-unix-transport
        --enable-tcp-transport
        --enable-ipv6
        --enable-local-transport
        --prefix=$mprefix
        --sysconfdir=$mprefix/etc
        --localstatedir=$mprefix/var
        --libdir=$mprefix/lib
    )
else
    autoreconf_args=(
        --force
        --verbose
        --install
        -I "$PREFIX/share/aclocal"
        -I "$BUILD_PREFIX/share/aclocal"
    )
    autoreconf "${autoreconf_args[@]}"

    export CONFIG_FLAGS="--build=${BUILD}"

    export PKG_CONFIG_LIBDIR=$uprefix/lib/pkgconfig:$uprefix/share/pkgconfig
    configure_args=(
        $CONFIG_FLAGS
        --disable-dependency-tracking
        --disable-selective-werror
        --disable-silent-rules
        --enable-unix-transport
        --enable-tcp-transport
        --enable-ipv6
        --enable-local-transport
        --prefix=$mprefix
        --sysconfdir=$mprefix/etc
        --localstatedir=$mprefix/var
        --libdir=$mprefix/lib
    )
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]] ; then
    configure_args+=(
        --enable-malloc0returnsnull
    )
fi
./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install

rm -rf $uprefix/share/man $uprefix/share/doc/${PKG_NAME#xorg-}

# Remove any new Libtool files we may have installed. It is intended that
# conda-build will eventually do this automatically.
find $uprefix/. -name '*.la' -delete
