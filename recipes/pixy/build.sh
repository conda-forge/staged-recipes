#!/bin/bash

SRC_DIR="${SRC_DIR}/src"

mkdir -p $PREFIX/bin
cp $SRC_DIR/pixy.py $PREFIX/bin/pixy
chmod +x $PREFIX/bin/pixy
