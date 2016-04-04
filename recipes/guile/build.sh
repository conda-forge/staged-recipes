#!/usr/bin/env bash

./configure --disable-dependency-tracking --disable-nls --prefix=${PREFIX}
make
make check
make install
