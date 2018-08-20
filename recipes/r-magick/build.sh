#!/bin/bash
if [[ $target_platform =~ linux.* ]] || [[ $target_platform == win-32 ]] || [[ $target_platform == win-64 ]] || [[ $target_platform == osx-64 ]]; then

  export CFLAGS="$(Magick++-config --cflags)"
  export LDFLAGS="$(Magick++-config --libs)"
  export LIB_DIR="$(Magick++-config --libs)"

  export DISABLE_AUTOBREW=1
  $R CMD INSTALL --build .
else
  mkdir -p $PREFIX/lib/R/library/magick
  mv * $PREFIX/lib/R/library/magick
fi
