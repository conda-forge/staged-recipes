#!/bin/bash

./configure \
             --prefix="${PREFIX}" \
             --with-pcre-prefix="${PREFIX}" \
             --with-boost="${PREFIX}" \
             --with-tcl="${PREFIX}" \
             --with-tclconfig="${PREFIX}/lib" \
             --without-alllang
make -j${CPU_COUNT}
#make check
make install
