#!/bin/bash

BIN=$PREFIX/bin

cd ${SRC_DIR}

# Build SDL2
./autogen.sh
./configure
make
make install