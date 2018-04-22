#!/bin/bash

ls ${PREFIX}
autoreconf -i
mkdir build
cd build
../configure --prefix=$PREFIX
make
make install
