#!/bin/bash

if [[ "$target_platform" == "osx-64" ]]; then
  sed -i.bak "s/-Wl,-soname=/-install_name /g" makefile
  OPTIONS="SONAME=liblrs.0.dylib SHLIB=liblrs.0.0.0.dylib SHLINK=liblrs.dylib"
fi
export CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
make INCLUDEDIR=${PREFIX}/include LIBDIR=${PREFIX}/lib prefix=$PREFIX all-shared install -j${CPU_COUNT} $OPTIONS
