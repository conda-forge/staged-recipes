#!/bin/sh

cd $SRC_DIR

autoreconf -f -i
./configure --prefix=$PREFIX --disable-silent-rules --disable-dependency-tracking
make
make install
