#!/bin/bash
sed -i -- "s|@prefix@|${PREFIX}|g" SDL2_ttf.pc.in
./configure --disable-dependency-tracking --prefix=${PREFIX}
make 
make check
make install
