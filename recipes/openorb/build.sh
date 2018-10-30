#!/bin/bash

# conda's gfortran on Linux does not install a binary named 'gfortran'
echo "gfortran = $(which gfortran)"
[[ ! -f "$BUILD_PREFIX/bin/gfortran" && ! -z "$GFORTRAN" ]] && ln -s "$GFORTRAN" "$BUILD_PREFIX/bin/gfortran"
echo "gfortran = $(which gfortran)"

./configure gfortran opt --prefix="$PREFIX"
make all
make install
