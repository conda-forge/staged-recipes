#!/bin/bash

make PREFIX=$PREFIX -j${CPU_COUNT}
make PREFIX=$PREFIX install

mkdir -p -m755 -v "$PREFIX"/bin
install -m755 -v h264dec "$PREFIX"/bin/h264dec
install -m755 -v h264enc "$PREFIX"/bin/h264enc

# debug command to see the linkage of the library
otool -L $PREFIX/lib/libopenh264.1.7.0.dylib
