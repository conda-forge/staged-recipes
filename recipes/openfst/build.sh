#! /usr/bin/env bash

autoconf
./configure --prefix=${PREFIX}
make install -j ${CPU_COUNT}
