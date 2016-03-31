#!/usr/bin/env bash

./configure --disable-dependency-tracking --prefix=${PREFIX}
make
make check
make install
