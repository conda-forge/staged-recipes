#!/bin/sh
ls -al
mkdir build
cd build
# NOTE : Doesn't seem to find mpfr automatically, so the extra flags are
# needed.
../configure --prefix=$PREFIX --disable-qt -with-mpfr-include=$PREFIX/include -with-mpfr-lib=$PREFIX/lib
make -j${CPU_COUNT}
make install
