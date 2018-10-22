#!/bin/bash

# conda's gfortran on Linux does not install a binary named 'gfortran'
echo "gfortran = $(which gfortran)"
[[ ! -f "$BUILD_PREFIX/bin/gfortran" && ! -z "$GFORTRAN" ]] && ln -s "$GFORTRAN" "$BUILD_PREFIX/bin/gfortran"
echo "gfortran = $(which gfortran)"

./configure gfortran opt --prefix="$PREFIX"

# Build JPL ephemeris
(cd data/JPL_ephemeris && make asc2eph && make ephtester)

# Install
mkdir -p "$PREFIX/bin"
cp -a data/getBC430 "$PREFIX/bin"
cp -a data/JPL_ephemeris/{asc2eph,ephtester} "$PREFIX/bin"
