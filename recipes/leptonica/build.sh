#!/usr/bin/env bash

./autobuild
./configure --prefix=$PREFIX
make -j$CPU_COUNT
make install
