#!/bin/bash

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

./configure --prefix=${PREFIX} --host=${HOST}
make -j${CPU_COUNT}
make install -j${CPU_COUNT}
