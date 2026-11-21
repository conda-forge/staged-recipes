#!/bin/sh
set -ex

# configure
# meson.build rejects optimization=3, which --buildtype=release sets
meson setup builddir ${MESON_ARGS} -Doptimization=2 -Ddebug=false

# build
meson compile -C builddir

# test?

# install
meson install -C builddir
