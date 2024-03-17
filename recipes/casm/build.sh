#!/bin/bash
autoconf
./configure
make
make check 
make install 
