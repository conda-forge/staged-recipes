#!/bin/bash
autoconf
automake
./configure
make
make check 
make install 
