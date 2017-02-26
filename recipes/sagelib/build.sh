#!/bin/bash

export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-w $CFLAGS"
export CXXFLAGS="-w $CXXFLAGS"

export SAGE_FAT_BINARY=yes
export SAGE_LOCAL=$PREFIX
ln -s $PREFIX local
export SAGE_NUM_THREADS=2

make build sagelib
