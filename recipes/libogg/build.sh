#!/bin/bash

# Build SDL2
./autogen.sh
./configure --prefix=${PREFIX}
make install
