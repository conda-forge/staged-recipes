#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig

# Poppler's zlib check doesn't let you specify its install prefix so we have
# to go global.
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

configure_args=(
    --prefix=$PREFIX
    --disable-dependency-tracking
    --enable-libcurl
    --enable-introspection=auto
    --disable-gtk-doc
    --disable-gtk-test
)

if [ $(uname) = Darwin ] ; then
    LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$CPU_COUNT
# make check requires a big data download
make install

pushd $PREFIX
rm -rf lib/libpoppler*.la lib/libpoppler*.a share/gtk-doc share/man
popd
