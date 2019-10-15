#!/bin/bash

cd asio

./autogen.sh
./configure --prefix=$PREFIX 

make -j${CPU_COUNT}
make install
