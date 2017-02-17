#!/bin/bash

export CFLAGS="-I${PREFIX}/include "${CFLAGS}
export LDFLAGS="-L${PREFIX}/lib "${LDFLAGS}

./configure  --prefix=$PREFIX --with-driver=osmesa --disable-egl --with-osmesa-bits=32
make -j${CPU_COUNT}
make install

