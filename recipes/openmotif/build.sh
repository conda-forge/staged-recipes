#!/bin/sh

if [ $(uname) = Darwin ] ; then
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            --disable-silent-rules



make -j${CPU_COUNT}
make install
