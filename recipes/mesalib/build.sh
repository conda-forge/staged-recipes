#!/bin/bash

export CFLAGS="-I${PREFIX}/include "${CFLAGS}
export LDFLAGS="-L${PREFIX}/lib "${LDFLAGS}

#./configure  --prefix=$PREFIX --enable-osmesa --disable-egl --with-osmesa-bits=32 --enable-gallium-osmesa --disable-dri #--with-gallium-drivers= #--with-dri-drivers=swrast #,i915,i965,r200,radeon #--with-llvm-prefix=${PREFIX}
./configure  --prefix=$PREFIX --with-driver=osmesa --disable-gallium --disable-gallium-intel --disable-egl
make -j${CPU_COUNT}
make install

