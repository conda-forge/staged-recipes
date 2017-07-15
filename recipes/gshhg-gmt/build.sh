#!/bin/bash

DATADIR="$PREFIX/share/gshhg-gmt"

mkdir -p $DATADIR

cp $SRC_DIR/*.nc $DATADIR/
cp $SRC_DIR/*.TXT $DATADIR/
cp $SRC_DIR/COPYING* $DATADIR/
