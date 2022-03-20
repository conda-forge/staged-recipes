#!/bin/bash

set -ex

find .
autoreconf --install
./configure --prefix="$PREFIX"

make -j "$CPU_COUNT"
make install

