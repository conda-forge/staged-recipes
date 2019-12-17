#!/bin/bash
./configure --prefix=$PREFIX --with-tcl=$PREFIX/lib/

make -j${CPU_COUNT}
make install
