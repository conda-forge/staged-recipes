#!/bin/bash

export CAIRO_CFLAGS="-I$PREFIX/include/cairo/"
export CAIRO_LIBS="-L$PREFIX/lib/ -lcairo"

export POPPLERGLIB_CFLAGS="-I$PREFIX/include/poppler/"
export POPPLERGLIB_LIBS="-L$HOME/anaconda/envs/cpp-dev/lib/ -lpoppler-glib -lgobject-2.0 -lglib-2.0"

# This needs to be done if building from master branch:
# mv README.md README

autoconf
automake -a
./configure --prefix="${PREFIX}"
make -j${CPU_COUNT}
make check -j${CPU_COUNT}
make install -j${CPU_COUNT}
