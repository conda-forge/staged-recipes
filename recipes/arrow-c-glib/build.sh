#!/usr/bin/env bash

set -e
set -x

meson setup \
  --prefix ${PREFIX} \
  --libdir ${PREFIX}/lib \
  --buildtype=release \
  c_glib.build c_glib

meson compile -C c_glib.build
meson install -C c_glib.build
