#!/bin/bash

mkdir build
cd build

# need gtkdoc-scan for doc buildin
rm ../docs/reference/meson.build
touch ../docs/reference/meson.build 

meson --buildtype=release --prefix="$PREFIX" --backend=ninja -Dlibdir=lib ..
ninja -j${CPU_COUNT}
ninja install

