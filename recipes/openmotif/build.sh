#!/bin/sh

if [ $(uname) = Darwin ] ; then
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

./configure --prefix=$PREFIX \
            --disable-silent-rules

#            --disable-dependency-tracking \

make -j${CPU_COUNT}
make install
