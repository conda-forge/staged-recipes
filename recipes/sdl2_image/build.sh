#!/bin/bash

cd ${SRC_DIR}

# Build
./configure --disable-dependency-tracking  --enable-imageio=no
make
make install