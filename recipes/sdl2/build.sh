#!/bin/bash
cd ${SRC_DIR}

 # we have to do this because most build scripts assume that all sdl modules
 # are installed to the same prefix.
sed -i -- "s|@prefix@|${PREFIX}|g" sdl2.pc.in 
sed -i -- "s|@prefix@|${PREFIX}|g" sdl2-config.in

# Build SDL2
./autogen.sh
./configure --prefix=${PREFIX} --disable-haptic --without-x
make install