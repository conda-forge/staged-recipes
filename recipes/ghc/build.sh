#!/bin/bash

export CFLAGS="-I$PREFIX/include" 
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
./configure --prefix $PREFIX --with-gmp-includes=$PREFIX/include --with-gmp-libraries=$PREFIX/lib
make install
#Small test
echo "main = putStr \"smalltest\"" > Main.hs
ghc -dynamic -v5 -o smalltest Main.hs 
./smalltest
