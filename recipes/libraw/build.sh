#!/bin/bash

autoreconf --install
./configure --prefix="${PREFIX}"

make -j${CPU_COUNT}
make install
