#!/bin/bash

./configure --disable-java --disable-php --disable-perl --disable-tcl --without-x --prefix="${PREFIX}"
make
make check
make install
dot -c
