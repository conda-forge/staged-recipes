#!/bin/bash

export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-w $CFLAGS"
export CXXFLAGS="-w $CXXFLAGS"

export SAGE_FAT_BINARY=yes
export SAGE_LOCAL=$PREFIX
ln -s $PREFIX local
export SAGE_NUM_THREADS=2

# make build builds sagelib and copies some scripts
# the scripts can be moved to another package and call it sageruntime
make build

#TODO: Add these in corresponding packages
rm $PREFIX/share/jupyter/kernels/sagemath/doc
rm $PREFIX/share/jupyter/nbextensions/mathjax
rm $PREFIX/share/jupyter/nbextensions/jsmol

#remove lib64 symlink for now until conda has better support
rm $PREFIX/lib64
