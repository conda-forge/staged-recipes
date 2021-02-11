#!/bin/bash

meson _build --prefix=${PREFIX} -Dlibdir=lib -Dbuildtype=release
pushd _build

# build
meson complile -v

# test
meson test

# install
meson install
