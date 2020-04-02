#!/bin/sh
set -ex

mkdir -p out/release
cd out/release
cmake ../..
make
make install
