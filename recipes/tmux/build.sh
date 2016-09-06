#!/bin/bash

chmod +x ./autogen.sh

# Needed for Linux build to work.
export CFLAGS="-I${PREFIX}/include ${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

./autogen.sh
./configure --prefix=$PREFIX
make
make install
