#!/bin/bash

set -e

test -d m4 || mkdir m4
gtkdocize || exit 1

export python=$PYTHON
export PATH=$BUILD_PREFIX/bin:$PATH
export PKG_CONFIG_LIBDIR="$BUILD_PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PKG_CONFIG_LIBDIR
export ACLOCAL_PATH="$BUILD_PREFIX/share/aclocal"
aclocal --print-ac-dir

autoreconf -ivf

./configure --disable-gui --enable-introspection=yes --disable-hkl-doc --prefix=$PREFIX 
# || { cat config.log ; exit 1 ; }
make -j
make install
