#!/usr/bin/env bash

./configure --prefix=$PREFIX || { cat config.log; exit 1; }
make SHLIB_LIBS="$(pkg-config --libs ncurses)"
make install
