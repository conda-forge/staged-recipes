#!/bin/bash

# Copied from r-gsl recipe:
# https://github.com/conda-forge/r-gsl-feedstock/blob/master/recipe/build.sh

export CFLAGS="$(gsl-config --cflags)"
export LDFLAGS="$(gsl-config --libs)"

# For whatever reason, it can't link to gsl correctly without this on OS X.
export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib

$R CMD INSTALL --build .
