#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./root-source/graf2d/asimage/src/libAfterImage

autoconf

./configure \
    --prefix="${PREFIX}" \
    --libdir="${PREFIX}/lib" \
    --with-zlib="${PREFIX}"

make -j${CPU_COUNT}

make -j${CPU_COUNT}install
