#!/usr/bin/env bash

./configure --prefix=$PREFIX --enable-thread=yes --enable-fortran=no --enable-shared=yes --enable-static=no

make -j${CPU_COUNT} VERBOSE=1

make install
