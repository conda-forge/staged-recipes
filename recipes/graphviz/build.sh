#!/bin/bash

export CFLAGS="-Wall -g -m${ARCH} -pipe -O2 -fPIC"
export CXXLAGS="${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

if [ `uname` == Darwin ]; then
    ./configure --prefix=$PREFIX \
                --with-quartz \
                --disable-debug \
                --disable-dependency-tracking \
                --disable-java \
                --disable-php \
                --disable-perl \
                --disable-tcl \
                --without-x \
                --without-qt
else
    ./configure --prefix=$PREFIX \
                --disable-java \
                --disable-php \
                --disable-perl \
                --disable-tcl \
                --without-x \
                --without-gtk
fi

make
# This is failing for rtest.
# Doesn't do anythoing for the rest
# make check
make install

dot -c
