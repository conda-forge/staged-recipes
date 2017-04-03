#!/bin/sh

cd $SRC_DIR

if [ "$(uname)" == "Darwin" ]
then
    export CXX="${CXX} -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
fi

autoreconf -f -i

./configure --prefix=$PREFIX --disable-silent-rules --disable-dependency-tracking
make
make install
