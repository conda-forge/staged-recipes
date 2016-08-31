#!/bin/bash

cd ${SRC_DIR}

# Build SDL2
./configure --disable-dependency-tracking --disable-sdltest
make
make install

 