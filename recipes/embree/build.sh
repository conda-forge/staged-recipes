#!/bin/bash
set -e
cd lib
if [ "$(uname)" == "Darwin" ]; then
  ln -s libembree.* libembree.dylib
else
  ln -s libembree.* libembree.so
fi
cd ..
cp -rv * "${PREFIX}"
