#!/bin/bash

DATADIR="$PREFIX/share/dcw-gmt"
mkdir -p $DATADIR

cp $SRC_DIR/*.txt $DATADIR
cp $SRC_DIR/*.TXT $DATADIR
cp $SRC_DIR/COPYING* $DATADIR
cp $SRC_DIR/*.nc $DATADIR
