#!/usr/bin/env bash

set -eu

if [[ $(uname -s) == "Linux" ]]; then
  ./unix/configure
  OUTPUT="bin/ds9"

else
  ./macos/configure
  OUTPUT="bin/SAOImageDS9.app"

fi

make
mkdir -p $PREFIX/bin
cp $OUTPUT $PREFIX/bin/ds9
