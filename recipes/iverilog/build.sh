#!/bin/bash

autoconf
./configure --prefix=$PREFIX
make
make check && make install
