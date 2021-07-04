#!/bin/bash

autoreconf -i
./configure --prefix=$PREFIX
make -j$CPU_COUNT
make install
