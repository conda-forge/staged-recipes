#!/bin/sh

mkdir build && cd build

meson --prefix=$PREFIX --libdir=$PREFIX/lib --buildtype=release -Dtests=false ..
ninja install
