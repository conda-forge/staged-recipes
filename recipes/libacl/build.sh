#!/usr/bin/env bash
autoconf
./configure --prefix=$PREFIX
make -j$CPU_COUNT
make install
