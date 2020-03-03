#! /bin/bash
# Prior to conda-forge, Copyright 2014-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

meson setup builddir -D enable_docs=false --prefix=$PREFIX --libdir=$PREFIX/lib
ninja -v -C builddir
ninja -C builddir install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf share/gtk-doc
