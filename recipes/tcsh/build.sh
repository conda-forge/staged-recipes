#!/bin/bash
set -eu -o pipefail

./configure --prefix="${PREFIX}" || { cat config.log; exit 1; }
make SHLIB_LIBS="$(pkg-config --libs ncurses)"
make check
make install 
