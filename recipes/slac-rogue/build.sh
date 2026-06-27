#!/bin/sh

mkdir -p build

cd build

cmake .. -DROGUE_INSTALL=system -DROGUE_VERSION=v6.6.2
make install
