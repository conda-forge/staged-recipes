#!/bin/bash

export CFLAGS="-I${PREFIX}/include "${CFLAGS}
export LDFLAGS="-L${PREFIX}/lib "${LDFLAGS}

./configure  --prefix=$PREFIX --with-driver=osmesa --disable-gallium --disable-gallium-intel --disable-egl
make -j${CPU_COUNT}
make install

