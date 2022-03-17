#!/bin/bash

set -ex

if [[ ! -f ./configure ]]; then
   autoreconf --install
fi

./configure --prefix="$PREFIX"

make -j "$CPU_COUNT"
make install

