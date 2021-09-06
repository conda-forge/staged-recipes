#!/bin/bash


autoreconf -i
automake --foreign -Wall
./configure --prefix=$PREFIX
make install
install -Dm644 libspiro.pc ${PREFIX}/lib/pkgconfig/libspiro.pc
