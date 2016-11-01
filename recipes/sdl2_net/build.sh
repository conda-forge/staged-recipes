#!/bin/bash
cd ${SRC_DIR}
./configure --disable-sdltest --disable-dependency-tracking --prefix=${PREFIX}
make install