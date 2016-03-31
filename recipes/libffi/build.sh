#!/usr/bin/env bash

./autogen.sh
./configure --disable-debug --disable-dependency-tracking --prefix=${PREFIX}
make
make check
make install
