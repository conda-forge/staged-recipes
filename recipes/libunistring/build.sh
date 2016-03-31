#!/usr/bin/env bash

./configure --disable-dependency-tracking --disable-silent-rules --prefix=${PREFIX}
make
make check
make install
