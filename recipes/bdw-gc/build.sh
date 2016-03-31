#!/usr/bin/env bash

./autogen.sh
./configure --disable-debug --disable-dependency-tracking --prefix=${PREFIX} --enable-cplusplus
make
make check
make install
