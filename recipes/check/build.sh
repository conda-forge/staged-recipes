#!/bin/bash

if [ ! -f configure ];
then
   autoreconf -i --force
fi

./configure --prefix=${PREFIX}

make
make check
make install
