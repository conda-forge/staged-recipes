#!/usr/bin/env bash

./configure --prefix=${PREFIX} --disable-buildprog
make -j${CPU_COUNT}
make check
make install
