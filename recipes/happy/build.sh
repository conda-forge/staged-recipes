#!/bin/bash
export CABAL_DIR="$PREFIX"
ghc-pkg recache
cabal update
cabal install --prefix=$PREFIX --bindir=$PREFIX/bin --libdir=$PREFIX/lib --ghc-options="-threaded" --extra-lib-dirs=$PREFIX/lib --extra-include-dirs=$PREFIX/include happy-1.19.9
