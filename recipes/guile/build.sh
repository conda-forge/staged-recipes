#!/usr/bin/env bash

./autogen.sh
./configure --disable-dependency-tracking --prefix=${PREFIX}
make
make check
make install
