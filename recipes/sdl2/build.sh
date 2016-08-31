#!/bin/bash

<<<<<<< b02e32cd84c6d76444a8171d41c5685fa3113bdb
# we have to do this because most build scripts assume that all sdl modules
# are installed to the same prefix.
sed -i -- "s|@prefix@|${PREFIX}|g" sdl2.pc.in 
sed -i -- "s|@prefix@|${PREFIX}|g" sdl2-config.in

# Build SDL2
./autogen.sh
./configure --prefix=${PREFIX} --disable-haptic --without-x
make install
=======
BIN=$PREFIX/bin

cd ${SRC_DIR}

# Build SDL2
./autogen.sh
./configure
make
make install
>>>>>>> Started with sdl2 recipes
