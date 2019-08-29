#!/bin/sh

# http://www.linuxfromscratch.org/blfs/view/6.3/general/libusb.html
export CFLAGS="$CFLAGS -Wno-error=format-truncation"
./configure --disable-build-docs --prefix=${PREFIX} --verbose
make
make install
make check
