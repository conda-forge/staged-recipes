#!/usr/bin/env bash

export CC="${CC}"
export CCC="${CXX}"

make

mkdir -p $PREFIX/bin

cp cccc/cccc $PREFIX/bin/
