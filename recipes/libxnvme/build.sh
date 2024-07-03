#!/usr/bin/env bash
meson setup builddir \
 -Ddefault_library=shared \
 -Dwith-spdk=false \
  $MESON_ARGS
meson compile -C builddir
meson install -C builddir
