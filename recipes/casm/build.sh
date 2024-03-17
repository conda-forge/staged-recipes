#!/bin/bash
aclocal
autoconf
automake --add-missing
./configure
make
make check 
make install 
