#! /bin/bash
set -ex

meson builddir --prefix=$PREFIX --libdir=$PREFIX/lib
meson configure -D enable_docs=false builddir
ninja -v -C builddir

ninja -C builddir test

ninja -C builddir install