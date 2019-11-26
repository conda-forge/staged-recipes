#!/bin/bash

set -evx

export CFLAGS="$CFLAGS -I$PREFIX/include/poppler -I$PREFIX/include/poppler/glib -I$PREFIX/include/glib-2.0 -I$PREFIX/lib/glib-2.0/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib/cairo -L$PREFIX/lib/glib-2.0 -lpoppler -lpoppler-glib -lgobject-2.0 -lglib-2.0 -lglib-2.0 -lcairo"

export CAIRO_CFLAGS="-I$PREFIX/include/cairo/"
export CAIRO_LIBS="-L$PREFIX/lib/ -lcairo"

export POPPLERGLIB_CFLAGS="-I$PREFIX/include/poppler/"
export POPPLERGLIB_LIBS="-L$PREFIX/lib/ -lpoppler-glib -lgobject-2.0 -lglib-2.0"

# This needs to be done if building from master branch:
# mv README.md README

aclocal
autoconf
automake -a
./configure --prefix="${PREFIX}"
make -j${CPU_COUNT}
make check -j${CPU_COUNT}
make install -j${CPU_COUNT}
