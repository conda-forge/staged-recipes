#!/bin/bash

./autogen.sh
./configure --prefix=$PREFIX --enable-watch8bit

make -j${CPU_COUNT}
make check
make install
