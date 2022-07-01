#!/bin/sh

meson --prefix=$CONDA_PREFIX --buildtype=release -Dtests=false ..
ninja install
