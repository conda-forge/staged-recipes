#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig

configure_args=(
    --prefix=$PREFIX
    --disable-dependency-tracking
    --with-cairo
)

if [ -n "$OSX_ARCH" ] ; then
    LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$CPU_COUNT
make install
make check
rm -f $PREFIX/lib/libgirepository-*.a $PREFIX/lib/libgirepository-*.la
