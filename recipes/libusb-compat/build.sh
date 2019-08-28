#!/bin/sh

# http://www.linuxfromscratch.org/blfs/view/6.3/general/libusb.html
export CFLAGS="$CFLAGS -Wno-error=format-truncation"
# export CXXFLAGS="$CXXFLAGS -Wno-error=format-truncation"
# export CPPFLAGS="$CPPFLAGS -Wno-error=format-truncation"
./configure --disable-build-docs --prefix=${PREFIX} --verbose
make
make install
