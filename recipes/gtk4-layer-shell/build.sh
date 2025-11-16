#! /bin/bash

set -ex

meson setup -Dexamples=false -Ddocs=false -Dtests=true --prefix=$PREFIX build
ninja -C build
ninja -C build install
ninja -C build test
ldconfig
