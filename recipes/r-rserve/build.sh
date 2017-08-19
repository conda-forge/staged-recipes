#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  PKG_LIBS="-L${PREFIX}/lib" $R CMD INSTALL --build .
else
  # .. on Linux the situation is even worse:
  LD_LIBRARY_PATH=${PREFIX}/lib/R/lib:${PREFIX}/lib \
  PKG_LIBS="-L${PREFIX}/lib -L${PREFIX}/lib/R/lib -lR -lRblas" \
    $R CMD INSTALL --build .
fi
