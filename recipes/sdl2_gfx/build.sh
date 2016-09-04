#!/bin/bash
cd ${SRC_DIR}
./configure --disable-dependency-tracking --disable-sdltest --prefix=${PREFIX}
make install

 