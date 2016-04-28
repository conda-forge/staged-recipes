#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"

autoreconf -vif

./configure --prefix=$PREFIX \
            --with-zlib-prefix=$PREFIX

make
make check
make install

cp $RECIPE_DIR/libpng-LICENSE.txt $SRC_DIR/libpng-LICENSE.txt
