#!/bin/bash
export CFLAGS="-I$PREFIX/include:$CFLAGS" 
export LDFLAGS="-L$PREFIX/lib:$LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
export C_INCLUDE_PATH="$PREFIX/include:$C_INCLUDE_PATH" 
ghc-pkg recache
cd cabal-install
export EXTRA_CONFIGURE_OPTS="--extra-include-dirs=$PREFIX/include --extra-lib-dirs=$PREFIX/lib $EXTRA_CONFIGURE_OPTS";
echo $EXTRA_CONFIGURE_OPTS
#export EXTRA_INSTALL_OPTS="--extra-include-dirs=$PREFIX/include --extra-lib-dirs=$PREFIX/lib $EXTRA_INSTALL_OPTS";
#echo $EXTRA_INSTALL_OPTS
./bootstrap.sh --no-doc
