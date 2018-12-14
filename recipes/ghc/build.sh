#!/bin/bash

export CFLAGS="-I$PREFIX/include" 
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
./configure --prefix $PREFIX
make install
#Small test
echo "main = putStr \"smalltest!\n\"" > Main.hs
ghc -v -o smalltest Main.hs
./smalltest
