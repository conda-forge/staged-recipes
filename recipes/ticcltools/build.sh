#!/bin/bash

sh bootstrap.sh
./configure --prefix=$PREFIX $OPENMPFLAG
make
make install
make check
