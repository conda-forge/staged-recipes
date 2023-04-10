#!/usr/bin/env bash

make amalg PREFIX=${PREFIX} XCFLAGS=-DLUAJIT_ENABLE_GC64 CC=${CC}
make install PREFIX=${PREFIX} XCFLAGS=-DLUAJIT_ENABLE_GC64 CC=${CC}

ln -sf ${PREFIX}/lib/libluajit-5.1${SHLIB_EXT} ${PREFIX}/lib/libluajit${SHLIB_EXT}

# Remove empty directories
rm -rf ${PREFIX}/lib/lua
rm -rf ${PREFIX}/share/lua
