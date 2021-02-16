#!/bin/bash

aclocal
automake --add-missing
autoconf

./configure --prefix=$PREFIX
make
make install
