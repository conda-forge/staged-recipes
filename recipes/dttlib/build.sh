#!/bin/sh

export LIBCLANG_PATH=$CONDA_PREFIX/lib
export C_INCLUDE_PATH=$CONDA_PREFIX/include
export CPLUS_INCLUDE_PATH=$CONDA_PREFIX/include

maturin develop --features python,python-pipe,nds --release

