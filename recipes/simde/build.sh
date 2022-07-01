#!/bin/sh

mkdir build && cd build

meson --prefix=$PREFIX --buildtype=release -Dtests=false ..
ninja install
