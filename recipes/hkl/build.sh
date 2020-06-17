#!/bin/bash

set -e

test -d m4 || mkdir m4
# gtkdocize || exit 1

# export python=$PYTHON
# export PATH=$PREFIX/bin:$PATH
# export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PKG_CONFIG_LIBDIR
export ACLOCAL_PATH="$PREFIX/share/aclocal"
aclocal --print-ac-dir

autoreconf -ivf

./configure --disable-static --disable-gui --enable-introspection=yes --disable-hkl-doc --prefix=$PREFIX
make -j ${CPU_COUNT}
make install
