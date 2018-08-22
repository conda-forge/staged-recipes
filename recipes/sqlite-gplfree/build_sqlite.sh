#!/bin/bash

export LDFLAGS="$LDFLAGS $(pkg-config --libs ncurses)"
export CPPFLAGS="$CPPFLAGS $(pkg-config --cflags-only-I ncurses)"
export CFLAGS="$CFLAGS $(pkg-config --cflags-only-I ncurses)"

if [ $(uname -m) == ppc64le ]; then
    export B="--build=ppc64le-linux"
fi

./configure SQLITE_ENABLE_RTREE=1 \
            $B --enable-threadsafe \
            --enable-json1 \
            --enable-tempstore \
            --enable-shared=yes \
            --disable-readline \
            --enable-editline \
            --disable-tcl \
            --prefix="${PREFIX}"

make
make check
make install

