#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig

configure_args=(
    --prefix=$PREFIX
    --disable-dependency-tracking
    --with-cairo
)

./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install
make check
rm -f $PREFIX/lib/libgirepository-*.a $PREFIX/lib/libgirepository-*.la
