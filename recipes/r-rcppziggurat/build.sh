#!/bin/bash
if [[ $target_platform =~ linux.* ]] || [[ $target_platform == win-32 ]] || [[ $target_platform == win-64 ]] || [[ $target_platform == osx-64 ]]; then
  # Copied from r-gsl recipe:
  # https://github.com/conda-forge/r-gsl-feedstock/blob/master/recipe/build.sh
  export CFLAGS="$(gsl-config --cflags)"
  export LDFLAGS="$(gsl-config --libs)"

  # For whatever reason, it can't link to gsl correctly without this on OS X.
  export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib

  export DISABLE_AUTOBREW=1
  $R CMD INSTALL --build .
else
  mkdir -p $PREFIX/lib/R/library/RcppZiggurat
  mv * $PREFIX/lib/R/library/RcppZiggurat
fi
