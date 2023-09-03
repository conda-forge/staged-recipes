#!/usr/bin/env bash

set -e

if [[ $(uname -s) == "Linux" ]]; then
  sed -i 's/tclsh/$(TCLSH_PROG)/' ds9/make.include     # https://github.com/SAOImageDS9/SAOImageDS9/issues/134
  ./unix/configure
else
  sed -i '' 's/tclsh/$(TCLSH_PROG)/' ds9/make.include
  ./macos/configure
fi

make

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
