#!/bin/bash

set -euxo pipefail

# libdisplay-info looks up hwdata with `dependency('hwdata', native: true)` to
# locate pnp.ids. That lookup has to resolve against the build environment,
# and meson reads the *_FOR_BUILD variables for the build machine when cross
# compiling. Without this, meson falls back to a hardcoded
# /usr/share/hwdata/pnp.ids and would either fail or silently bake in data
# from the build image rather than from the hwdata package.
export PKG_CONFIG_PATH_FOR_BUILD="${BUILD_PREFIX}/share/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig"
export PKG_CONFIG_PATH="${BUILD_PREFIX}/share/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"

meson setup builddir \
  ${MESON_ARGS} \
  --wrap-mode=nodownload

# Fail loudly rather than silently shipping a PNP table built from whatever
# pnp.ids happened to be present on the build image.
grep -qE "dependency hwdata found: YES" builddir/meson-logs/meson-log.txt

meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir
