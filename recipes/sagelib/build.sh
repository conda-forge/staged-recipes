#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-O2 -g -fPIC -w $CFLAGS"
export CXXFLAGS="-O2 -g -fPIC -w $CXXFLAGS"

export SAGE_FAT_BINARY=yes
export SAGE_LOCAL=$PREFIX
ln -s $PREFIX local

echo $CIRCLE_ARTIFACTS
echo $PATH
set -o pipefail && make build sagelib -j${CPU_COUNT} | tee ~/config.log
cat config.log
cp config.log $CIRCLE_ARTIFACTS
