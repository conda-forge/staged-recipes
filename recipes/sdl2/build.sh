#!/bin/bash
<<<<<<< c829c3002c3dbc14fe964fce99bb87a95b888225
<<<<<<< 6f3252e3a8cae52b92ce713515e3a2ace482b6c3

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

=======
>>>>>>> all sdl recipes working, added pysdl2
cd ${SRC_DIR}
=======
>>>>>>> Process feedback of @patricksnape

# we have to do this because most build scripts assume that all sdl modules
# are installed to the same prefix.
sed -i -- "s|@prefix@|${PREFIX}|g" sdl2.pc.in 
sed -i -- "s|@prefix@|${PREFIX}|g" sdl2-config.in

# Build SDL2
./autogen.sh
<<<<<<< 6f3252e3a8cae52b92ce713515e3a2ace482b6c3
./configure
make
make install
>>>>>>> Started with sdl2 recipes
=======
./configure --prefix=${PREFIX} --disable-haptic --without-x
make install
<<<<<<< c829c3002c3dbc14fe964fce99bb87a95b888225
>>>>>>> all sdl recipes working, added pysdl2
=======
>>>>>>> Process feedback of @patricksnape
