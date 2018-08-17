#!/usr/bin/env bash

./Configure -n $(uname|tr '[:upper:]' '[:lower:]')
make -j${CPU_COUNT}
mkdir -p $PREFIX/bin/
cp ./lsof $PREFIX/bin/
