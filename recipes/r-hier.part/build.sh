#!/bin/bash

if [[ $target_platform =~ linux.* ]] || [[ $target_platform == win-32 ]] || [[ $target_platform == win-64 ]] || [[ $target_platform == osx-64 ]]; then
  export DISABLE_AUTOBREW=1
  mv DESCRIPTION DESCRIPTION.old
  grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
  $R CMD INSTALL --build --configure-args="--prefix=$PREFIX" .
else
  mkdir -p $PREFIX/lib/R/library/hier.part
  mv * $PREFIX/lib/R/library/hier.part
fi
