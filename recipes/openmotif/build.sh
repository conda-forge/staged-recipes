#!/bin/sh

export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib

./configure --prefix=$PREFIX \
            --disable-silent-rules

#            --disable-dependency-tracking \

make
make install
