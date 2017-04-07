#!/bin/bash

export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
$R CMD INSTALL --build --configure-args="--with-nlopt-cflags=-I${PREFIX}/include --with-nlopt-libs=\"-L${PREFIX}/lib -lnlopt\"" .
