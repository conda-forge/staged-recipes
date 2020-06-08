#!/usr/bin/env bash

libtoolize --force --copy --automake
aclocal
autoheader
automake --foreign --copy --add-missing
autoconf
./configure --prefix=$PREFIX --build=$BUILD --host=$HOST
make -j${CPU_COUNT}
make check
make install
