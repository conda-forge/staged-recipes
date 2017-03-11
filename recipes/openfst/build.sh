#! /usr/bin/env bash

autoconf
chmod +x ./configure
./configure --prefix=${PREFIX}
make install -j ${CPU_COUNT}
