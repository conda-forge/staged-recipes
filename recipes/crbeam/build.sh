#!/bin/bash
cmake -D CMAKE_VERBOSE_MAKEFILE=ON src/app/crbeam
make
cp CRbeam  $PREFIX/bin/crbeam
mkdir -p $PREFIX/share/crbeam/
cp -R bin/tables $PREFIX/share/crbeam/
