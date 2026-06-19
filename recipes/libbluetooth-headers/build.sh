#!/bin/sh

set -e

mkdir -p $PREFIX/include/bluetooth

cp -r lib/*.h $PREFIX/include/bluetooth/
