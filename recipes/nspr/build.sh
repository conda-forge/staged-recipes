#!/usr/bin/env bash

cd nspr

./configure --prefix="${PREFIX}" --enable-64bit

make -j $CPU_COUNT
make install
