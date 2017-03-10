#! /usr/bin/env bash

chmod +x ./configure
./configure --prefix=${PREFIX}
make install -j ${CPU_COUNT}
