#!/bin/bash
./configure \
    --prefix=$PREFIX \
    --with-tcl=$PREFIX/lib \
    --with-readline-includes=$PREFIX/include/readline \
    --with-readline-library="$PREFIX/lib/readline${SHLIB_EXT}"

make -j${CPU_COUNT}
make install
