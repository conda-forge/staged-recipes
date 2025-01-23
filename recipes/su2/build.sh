#!/usr/bin/env bash

set -xe

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

./meson.py build --prefix=${PREFIX} -Denable-openblas=true -Denable-pywrapper=true -Denable-autodiff=true -Denable-directdiff=true

./ninja -C build install
