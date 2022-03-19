#!/bin/bash

set -ex

autoreconf --install
./configure --prefix="$PREFIX"

make -j "$CPU_COUNT"
make install

