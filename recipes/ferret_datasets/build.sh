#!/bin/bash

mkdir -p $PREFIX/share/fer_dsets
cp -r $SRC_DIR/data $PREFIX/share/fer_dsets/data
cp -r $SRC_DIR/descr $PREFIX/share/fer_dsets/descr
cp -r $SRC_DIR/grids $PREFIX/share/fer_dsets/grids
