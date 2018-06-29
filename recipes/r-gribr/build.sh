#!/bin/bash

export ECCODES_LIBS="-L$PREFIX/lib"
export ECCODES_CPPFLAGS="-I$PREFIX/include"

$R CMD INSTALL --build .
