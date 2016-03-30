#!/usr/bin/env bash

./configure --disable-debug --disable-dependency-tracking --disable-silent-rules --prefix=${PREFIX}
make
make install
