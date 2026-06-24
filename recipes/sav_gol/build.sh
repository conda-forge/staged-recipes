#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
mkdir -p $SRC_DIR/bin

./configure --prefix=$SRC_DIR
(cd source_c/ && make sav_gol)

cp source_c/sav_gol $PREFIX/bin/sav_gol
chmod +x $PREFIX/bin/sav_gol
