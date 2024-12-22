#!/bin/bash

export LC_ALL=C
export NINJA=$(which ninja)
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"

meson setup build -Dopengl=disabled ${MESON_ARGS}

meson compile -C build --verbose
meson install -C build

