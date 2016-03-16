#!/bin/sh


if [[ ${ARCH:-32} == "64" ]]; then
    DEFS='-DUSE_PNG -DUSE_JPEG2000 -D__64BIT__';
else
    DEFS='-DUSE_PNG -DUSE_JPEG2000';
fi

export DEFS
CFLAGS="$CFLAGS $DEFS -fPIC -I${PREFIX}/include"
export CFLAGS

make -e
cp *.h ${PREFIX}/include
cp libgrib2c.a ${PREFIX}/lib
