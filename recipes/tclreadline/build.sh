#!/bin/bash
./configure --prefix=$PREFIX --with-tcl=$PREFIX/lib/ --with-readline-includes=$PREFIX/include/readline/

make -j${CPU_COUNT}
make install
