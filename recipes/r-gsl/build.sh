#!/bin/bash

export CFLAGS="$(gsl-config --cflags)"
export LDFLAGS="$(gsl-config --libs)"

# For whatever reason, it can't link to gsl correctly without this on OS X.
export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib

$R CMD INSTALL --build .
