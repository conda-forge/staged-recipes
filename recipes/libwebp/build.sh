#!/bin/bash

# The libwebp build script doesn't pick all the other libraries up on its own
# (even though it should by using PREFIX), so pass all the necessary parameters
# for finding other imaging libraries to the configure script.
./configure --prefix=${PREFIX} --exec-prefix=${PREFIX} \
	--enable-libwebpmux --enable-libwebpdemux --enable-libwebpdecoder --disable-dependency-tracking \
	--with-jpeglibdir=${PREFIX}/lib --with-jpegincludedir=${PREFIX}/include \
	--with-tifflibdir=${PREFIX}/lib --with-tiffincludedir=${PREFIX}/include \
	--with-giflibdir=${PREFIX}/lib --with-gifincludedir=${PREFIX}/include
make 
make check
make install
