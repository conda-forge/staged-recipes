#!/usr/bin/env bash

./autogen.sh
./configure --prefix=${PREFIX}
make -j 2
make install