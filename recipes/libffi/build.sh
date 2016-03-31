#!/usr/bin/env bash

./configure --disable-debug --disable-dependency-tracking --prefix=${PREFIX}
make
make check
make install
