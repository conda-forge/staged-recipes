#! /bin/bash

meson --prefix=$PREFIX --libdir=lib -Dexamples=false -Dutils=false build
ninja -C build/
ninja -C build/ install
