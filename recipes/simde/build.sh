#!/bin/sh

mkdir build && cd build

meson --prefix=$CONDA_PREFIX --buildtype=release -Dtests=false ..
ninja install
