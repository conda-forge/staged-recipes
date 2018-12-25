#!/bin/bash

export CFLAGS="-I$PREFIX/include:$CFLAGS" 
export LDFLAGS="-L$PREFIX/lib:$LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
./bootstrap.sh
