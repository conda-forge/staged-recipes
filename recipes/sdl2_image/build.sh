#!/bin/bash
cd ${SRC_DIR}
./configure --disable-dependency-tracking  --enable-imageio=no --prefix=${PREFIX}
make install