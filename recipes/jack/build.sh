#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib $LDFLAGS"
export CPPFLAGS="-I${PREFIX}/include $CPPFLAGS"
export CFLAGS="-fPIC $CFLAGS"

./configure --prefix=$PREFIX

make -j$CPU_COUNT
make check -j$CPU_COUNT
make install -j$CPU_COUNT


# Conda uses only /lib for everything.
mkdir -p $PREFIX/lib
mv $PREFIX/lib64/* $PREFIX/lib

cd $PREFIX
find . -type f -name "*.la" -exec rm -rf '{}' \; -print
